//
//  TrickleWebSocket.swift
//  TrickleKit
//
//  Created by Chocoford on 2022/12/10.
//

import Foundation
import Logging
import TrickleCore
import TrickleSocketSupport

public class TrickleWebSocket {
    let logger = Logger(label: "TrickleWebSocket")
    
    var onMessage: (IncomingMessageType) -> Void
    
    var stream: WebSocketStream? = nil
    var socketSession: URLSession = .shared
        
    var token: String? = nil
    var userID: String? = nil
    
    var configs: ConnectData? {
        willSet {
            guard let configs = configs else { return }
            for timers in self.timers.values {
                timers.invalidAll()
            }
            timers[configs.connectionID] = nil
        }
    }
    
    struct Timers {
        var helloInterval: Timer?
        var deadCountdown: Timer?
        var ping: Timer?
        var roomHello: Timer?
        var roomDead: Timer?
        
        func invalidAll() {
            helloInterval?.invalidate()
            deadCountdown?.invalidate()
            ping?.invalidate()
            roomHello?.invalidate()
            roomDead?.invalidate()
        }
    }
    var timers: [String : Timers] = [:]
    
    var workspaceID: String?
    var memberID: String?
        
    public init(handlers: @escaping (IncomingMessageType) -> Void) {
        self.onMessage = handlers
    }
    
    
    public func initSocket(token: String, userID: String) {
        self.token = "Bearer \(token)"
        self.userID = userID
        let wsURL = URL(string: "wss://\(TrickleEnv.webSocketDomain)?authToken=Bearer%20\(token)")
        guard let url = wsURL else { return }
        
        stream = WebSocketStream(url: url, session: socketSession)
        Task {
            await send(.connect)
            /// handle internal messages
            do {
                for try await message in stream! {
                    handleMessage(message)
                }
            } catch {
                logger.error("\(error.localizedDescription)")
            }
        }
    }
    
    public func reinitSocket() {
        guard let token = self.token,
              let userID = self.userID else { return }
        self.initSocket(token: token, userID: userID)
    }
    
    private func send(_ message: MessageType) async {
        switch message {
            case .connect:
                await stream?.send(message: OutgoingEmptyMessage(authorization: self.token, action: .message, path: .connect))
            case .hello(let data):
                await stream?.send(message: OutgoingMessage(action: .message, path: .hello, data: data))
            case .subscribeWorkspaces(let data):
                await stream?.send(message: OutgoingMessage(authorization: self.token, action: .message, path: .subscribe, data: data))
            case .joinRoom(let data):
                await stream?.send(message: OutgoingMessage(authorization: self.token, action: .message, path: .joinRoom, data: data))
            case .roomStatus(let data):
                await stream?.send(message: OutgoingMessage(authorization: self.token, action: .message, path: .roomStatus, data: data))
            case .leaveRoom(let data):
                await stream?.send(message: OutgoingMessage(action: .message, path: .leaveRoom, data: data))
        }
    }
    
    public func close() {
        Task {
            if let workspaceID = workspaceID,
               let memberID = memberID {
               await leaveRoom(workspaceID: workspaceID, memberID: memberID)
            }
            timers.values.forEach { timer in
                timer.invalidAll()
            }
        }
    }
}

// MARK: Public API
extension TrickleWebSocket {
    public func subscribeWorksaces(_ ids: [WorkspaceData.ID], userID: String) async {
        await send(.subscribeWorkspaces(data: .init(workspaceIds: ids, userId: userID)))
    }
    
    public func joinRoom(workspaceID: WorkspaceData.ID, memberID: MemberData.ID) async {
        let workspaceID = "workspace:" + workspaceID
        self.workspaceID = workspaceID
        self.memberID = memberID
        await send(.joinRoom(data: .init(roomID: workspaceID, memberID: memberID, status: .online)))
    }
    
    public func leaveRoom(workspaceID: WorkspaceData.ID, memberID: MemberData.ID) async {
        guard let connectionID = self.configs?.connectionID else { return }
        let workspaceID = "workspace:" + workspaceID
        self.workspaceID = nil
        self.memberID = nil
        self.timers[connectionID]?.roomHello?.invalidate()
        self.timers[connectionID]?.roomHello = nil
        await send(.leaveRoom(data: .init(roomID: workspaceID, memberID: memberID, status: .offline)))
    }
}

// MARK: - Handle Message
extension TrickleWebSocket {
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
            case .data:
                fatalError()
            case .string(let string):
                handleMessage(string)
            @unknown default:
                fatalError()
        }
    }
    private func handleMessage(_ message: String) {
        DispatchQueue.main.async {
            TrickleSocketMessageHandler.shared.handleMessage(message) { event in
                switch event {
                    case .connectSuccess(let messageData):
                        self.onConnect(messageData)
                    case .helloAck(let messageData):
                        self.onHelloAck(messageData)
                    case .joinRoomAck(let messageData):
                        self.onJoinRoomAck(messageData)
                    default:
                        break
                }
                
                self.onMessage(event)
            }
        }
    }
    
    private func onConnect(_ data: IncomingMessage<[ConnectData]>) {
        guard let data = data.data?.first else {
            logger.error("invalid data")
            return
        }
        self.configs = data
        timers[data.connectionID] = .init()
        /// timer must initialize in main loop
        DispatchQueue.main.async {
            /// 开启hello机制
            let helloTimer = Timer.scheduledTimer(withTimeInterval: Double(data.helloInterval),
                                                  repeats: true) { timer in
                Task {
                    await self.send(.hello(data: .init(userID: self.userID ?? "")))
                }
            }
            self.timers[data.connectionID]?.helloInterval = helloTimer
            
//            /// 同时开启10秒一次的ping
//            let pingTimer = Timer.scheduledTimer(withTimeInterval: 10,
//                                                 repeats: true) { timer in
//                self.stream?.ping()
//            }
//
//            self.timers[data.connectionID]?.ping = pingTimer
        }
        
        /// tell sream is ready to clear waitlist
        stream?.isSocketReady = true
    }
    
    private func onHelloAck(_ data: IncomingMessage<[HelloAckData]>) {
        guard let _ = data.data else { return }
//        self.configs?.connectionID = data.connectionID
        setDeadTimer()
    }
    
    private func setDeadTimer() {
        guard let configs = configs else { return }
        timers[configs.connectionID]?.deadCountdown?.invalidate()
        let dead = Timer.scheduledTimer(withTimeInterval: Double(configs.deadInterval),
                             repeats: false) { timer in
            self.reinitSocket()
        }
        timers[configs.connectionID]?.deadCountdown = dead
    }
    
    private func onJoinRoomAck(_ data: IncomingMessage<[RoomStatusData]>) {
        guard let configs = self.configs,
              let data = data.data?.first,
              let workspaceID = data.roomID.components(separatedBy: ":").last else { return }
        DispatchQueue.main.async {
            /// 开启`room_status_hello`机制
            let helloTimer = Timer.scheduledTimer(withTimeInterval: Double(self.configs?.roomStatusHelloInterval ?? 30),
                                                  repeats: true) { timer in
                
                Task {
                    await self.send(.roomStatus(data: .init(roomID: workspaceID, memberID: data.memberID, status: .online)))
                }
            }
            self.timers[configs.connectionID]?.roomHello = helloTimer
        }
    }

}

// MARK: - internal interface
private extension TrickleWebSocket {
    typealias Configs = ConnectData
}
