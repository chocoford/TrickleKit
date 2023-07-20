//
//  SocketMessageHandler.swift
//  
//
//  Created by Dove Zachary on 2023/5/25.
//

import Foundation
import Logging

public enum IncomingMessageType {
    case connectSuccess(IncomingMessage<[ConnectData]>)
    case helloAck(IncomingMessage<[HelloAckData]>)
    case joinRoomAck(IncomingMessage<[RoomStatusData]>)
    
    case joinRoom(IncomingMessage<[RoomStatusData]>)
    case roomMembers(IncomingMessage<[RoomMembers]>)
    case roomStatus(IncomingMessage<[RoomStatusData]>)
    
    /// actions
    case sync(IncomingMessage<[RoomMembers]>)
    case changeNotify(IncomingMessage<[ChangeNotifyData]>)
}

public class TrickleSocketMessageHandler {
    public static var shared: TrickleSocketMessageHandler = .init()
    
    let logger = Logger(label: "TrickleSocketMessageHandler")
    
    private init() {}
    
    public func handleMessage(_ message: String, onEvent: (IncomingMessageType) -> Void) {
        let msgDic = message.toJSON() ?? [:]
        guard let rawPath = msgDic["path"] as? String else {
            self.logger.error("\(msgDic)")
            return
        }
        
        switch IncomingMessagePath(rawValue: rawPath) {
            case .connectSuccess:
                self.logger.info("on connect: \(message)")
                guard let messageData = message.decode(IncomingMessage<[ConnectData]>.self) else { break }
                onEvent(.connectSuccess(messageData))
                return
                
            case .helloAck:
                self.logger.info("on hello ack: \(message)")
                guard let messageData = message.decode(IncomingMessage<[HelloAckData]>.self) else { break }
                onEvent(.helloAck(messageData))
                return
                
            case .roomMembers:
                self.logger.info("on room members: \(message)")
                guard let messageData = message.decode(IncomingMessage<[RoomMembers]>.self) else { break }
                onEvent(.roomMembers(messageData))
                return
                
            case .sync:
                guard let messageData = message.decode(IncomingMessage<[RoomMembers]>.self) else { break }
                onEvent(.sync(messageData))
                return
                
            case .changeNotify:
                self.logger.info("on change notify: \(message)")
                guard let messageData = message.decode(IncomingMessage<[ChangeNotifyData]>.self, onFailed: { error in
                    dump(error)
                }) else { break }
                onEvent(.changeNotify(messageData))
                return
                
            case .joinRoomAck:
                self.logger.info("on join room ack: \(message)")
                guard let messageData = message.decode(IncomingMessage<[RoomStatusData]>.self) else { break }
                onEvent(.joinRoomAck(messageData))
                return
                
            case .joinRoom:
                self.logger.info("on join room: \(message)")
                guard let messageData = message.decode(IncomingMessage<[RoomStatusData]>.self) else { break }
                onEvent(.joinRoom(messageData))
                return
                
            case .roomStatus:
                self.logger.info("on room status: \(message)")
                guard let messageData = message.decode(IncomingMessage<[RoomStatusData]>.self) else { break }
                onEvent(.roomStatus(messageData))
                return
                
                
            case .none:
                self.logger.error("Unknown path: \(rawPath)")
                return
        }
        
        self.logger.error("Unhandled message: \(msgDic)")
    }
}
