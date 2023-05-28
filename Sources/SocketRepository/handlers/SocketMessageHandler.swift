//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/25.
//

import Foundation
import Logging

extension TrickleWebSocket {
    public enum IncomingMessageType {
        case connectSuccess(IncomingMessage<[TrickleWebSocket.ConnectData]>)
        case helloAck(IncomingMessage<TrickleWebSocket.HelloAckData>)
        case joinRoomAck(TrickleWebSocket.IncomingEmptyMessage)
        case roomMembers(IncomingMessage<[TrickleWebSocket.RoomMembers]>)
        
        /// actions
        case sync(IncomingMessage<[TrickleWebSocket.RoomMembers]>)
        case changeNotify(IncomingMessage<[TrickleWebSocket.ChangeNotifyData]>)
    }
}

public class TrickleSocketMessageHandler {
    typealias IncomingMessagePath = TrickleWebSocket.IncomingMessagePath
    typealias IncomingMessage = TrickleWebSocket.IncomingMessage
    typealias IncomingEmptyMessage = TrickleWebSocket.IncomingEmptyMessage
    
    public static var shared: TrickleSocketMessageHandler = .init()
    
    let logger = Logger(label: "TrickleSocketMessageHandler")
    
    private init() {}
    
    public func handleMessage(_ message: String, onEvent: (TrickleWebSocket.IncomingMessageType) -> Void) {
        let msgDic = message.toJSON() ?? [:]
        guard let rawPath = msgDic["path"] as? String else {
            return
        }
        
        switch IncomingMessagePath(rawValue: rawPath) {
            case .connectSuccess:
                guard let messageData = message.decode(IncomingMessage<[TrickleWebSocket.ConnectData]>.self) else { fallthrough }
                self.logger.info("on connect: \(messageData.description)")
                onEvent(.connectSuccess(messageData))
                
            case .helloAck:
                guard let messageData = message.decode(IncomingMessage<TrickleWebSocket.HelloAckData>.self) else { fallthrough }
                self.logger.info("on hello ack: \(messageData.description)")
                onEvent(.helloAck(messageData))
                
            case .joinRoomAck:
                guard let messageData = message.decode(TrickleWebSocket.IncomingEmptyMessage.self) else { fallthrough }
                self.logger.info("on join room ack: \(messageData.description)")
                onEvent(.joinRoomAck(messageData))
                
            case .roomMembers:
                guard let messageData = message.decode(IncomingMessage<[TrickleWebSocket.RoomMembers]>.self) else { fallthrough }
                self.logger.info("on room members: \(messageData.description)")
                onEvent(.roomMembers(messageData))
            case .sync:
                guard let messageData = message.decode(IncomingMessage<[TrickleWebSocket.RoomMembers]>.self) else { fallthrough }
                onEvent(.sync(messageData))
                
            case .changeNotify:
                guard let messageData = message.decode(IncomingMessage<[TrickleWebSocket.ChangeNotifyData]>.self, onFailed: { error in
                    dump(error)
                }) else { fallthrough }
                self.logger.info("on change notify: \(messageData.description)")
                onEvent(.changeNotify(messageData))
                
            case .none:
                self.logger.error("Unhandled message: \(msgDic)")
        }
    }
}
