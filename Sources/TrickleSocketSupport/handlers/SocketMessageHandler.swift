//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/25.
//

import Foundation
import Logging

public enum IncomingMessageType {
    case connectSuccess(IncomingMessage<[ConnectData]>)
    case helloAck(IncomingMessage<HelloAckData>)
    case joinRoomAck(IncomingEmptyMessage)
    case roomMembers(IncomingMessage<[RoomMembers]>)
    
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
            return
        }
        
        switch IncomingMessagePath(rawValue: rawPath) {
            case .connectSuccess:
                guard let messageData = message.decode(IncomingMessage<[ConnectData]>.self) else { fallthrough }
                self.logger.info("on connect: \(messageData.description)")
                onEvent(.connectSuccess(messageData))
                
            case .helloAck:
                guard let messageData = message.decode(IncomingMessage<HelloAckData>.self) else { fallthrough }
                self.logger.info("on hello ack: \(messageData.description)")
                onEvent(.helloAck(messageData))
                
            case .joinRoomAck:
                guard let messageData = message.decode(IncomingEmptyMessage.self) else { fallthrough }
                self.logger.info("on join room ack: \(messageData.description)")
                onEvent(.joinRoomAck(messageData))
                
            case .roomMembers:
                guard let messageData = message.decode(IncomingMessage<[RoomMembers]>.self) else { fallthrough }
                self.logger.info("on room members: \(messageData.description)")
                onEvent(.roomMembers(messageData))
            case .sync:
                guard let messageData = message.decode(IncomingMessage<[RoomMembers]>.self) else { fallthrough }
                onEvent(.sync(messageData))
                
            case .changeNotify:
                guard let messageData = message.decode(IncomingMessage<[ChangeNotifyData]>.self, onFailed: { error in
                    dump(error)
                }) else { fallthrough }
                self.logger.info("on change notify: \(messageData.description)")
                onEvent(.changeNotify(messageData))
                
            case .none:
                self.logger.error("Unhandled message: \(msgDic)")
        }
    }
}
