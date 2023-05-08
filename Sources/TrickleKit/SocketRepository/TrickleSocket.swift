//
//  TrickleSocket.swift
//  
//
//  Created by Dove Zachary on 2023/5/7.
//

//import Foundation
//import SocketIO
//
//class TrickleSocket {
//    let manager: SocketManager
//    let socket: SocketIOClient
//    
//    var trickleStore: TrickleStore?
//    
//    init() {
//        self.manager = SocketManager(socketURL: URL(string: "wss://\(Config.webSocketDomain)")!, config: [.log(true), .compress])
//        self.socket = manager.defaultSocket
//        configuration()
//    }
//    
//    func configuration() {
//        socket.on(clientEvent: .connect) {data, ack in
//            print("socket connected")
//        }
//        
//        socket.connect()
//    }
//    
//}
