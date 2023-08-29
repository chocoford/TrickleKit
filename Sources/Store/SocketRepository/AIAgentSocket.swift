//
//  TrickleAgentSocket.swift
//
//
//  Created by Dove Zachary on 2023/7/15.
//

import Foundation
import SocketIO
import TrickleCore
import OSLog

class TrickleAIAgentSocketLogger: SocketLogger {
    var log: Bool = true
    let logger: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: "TrickleAIAgentSocket")
    func log(_ message: @autoclosure () -> String, type: String) {
        let msg = message()
        logger.log("\(type): \(msg)")
    }
    
    func error(_ message: @autoclosure () -> String, type: String) {
        let msg = message()
        logger.error("\(type): \(msg)")
    }
    
    func debug(_ message: String) {
        logger.debug("\(message)")
    }
    
    func info(_ message: String) {
        logger.info("\(message)")
    }
}

public final class TrickleAIAgentSocketClient {
    var socketManager: SocketManager? = nil
    var socket: SocketIOClient? = nil
//    var token: String
    
    var onConnected: (() -> Void)? = nil
    
    var onEvents: (IncomingMessage) async -> Void
    
    public init(onEvents: @escaping (IncomingMessage) async -> Void) {
        self.onEvents = onEvents
    }
    
    let logger: TrickleAIAgentSocketLogger = .init()
    
    func configSocket(token: String) {
        let url = URL(string: "https://\(Config.aiActionDomain)")!
        self.socketManager = SocketManager(socketURL: url,
                                    config: [
                                        .logger(logger),
                                        .log(true),
                                        .compress,
                                        .connectParams(["token" : "Bearer \(token)"]),
                                        .path("/trickleai-sio"),
                                        .secure(true)
                                    ])
        
        self.socket = self.socketManager?.defaultSocket
        
        self.socket?.on(clientEvent: .connect) {data, ack in
//            print("socket connected")
            self.onConnected?()
        }
//        self.socket?.on(clientEvent: .error) {data, ack in
//            self.logger.debug("socket connect error: \(data)")
//        }
//        self.socket?.on(clientEvent: .reconnect) {data, ack in
//            self.logger.debug("socket reconnecting...")
//        }
//        self.socket?.on(clientEvent: .statusChange) {data, ack in
//            self.logger.debug("socket status changed: \(data)")
//        }
//        self.socket?.on(clientEvent: .disconnect) {data, ack in
//            self.logger.debug("socket status disconnected: \(data)")
//        }
//        self.socket?.on(clientEvent: .websocketUpgrade) {data, ack in
//            self.logger.debug("socket websocketUpgraded: \(data)")
//        }
        
        self.socket?.connect()
        self.onExternalMessage()
    }
}

public extension TrickleAIAgentSocketClient {
    func conntect(token: String, onConnected: (() -> Void)? = nil) {
        self.onConnected = onConnected
        configSocket(token: token)
    }
}


// MARK: - Public API
public extension TrickleAIAgentSocketClient {
    enum SocketError: LocalizedError {
        case responseTypeError
        
        public var errorDescription: String {
            switch self {
                case .responseTypeError:
                    return "Socket response is not an array or has no items."
            }
        }
    }
    
    enum SocketEvent: String {
        case listPublishedAgentConfigs
        case startConversationInWorkspace
        case syncConversation
        case newMessage
        case executeToolConfig
        case clearMessages = "clearConversation"
    }
    
    enum IntergrationType: String {
        case github, notion
    }
    
    struct EmptyData: Codable {}
    
    // List Published Agent Config
    func listPublishedAgentConfigs() async throws -> [AIAgentData] {
        let res: SocketResponse<[[AIAgentData]]>? = try await self.socket?.send(.listPublishedAgentConfigs)
        return res?.first?.results.first ?? []
    }
    
    struct StartConversationPayload: Codable {
        var workspaceID: WorkspaceData.ID
        var memberID: MemberData.ID
        var agentConfigID: AIAgentData.ID
        var channels: [Channel]
        
        enum CodingKeys: String, CodingKey {
            case workspaceID = "workspaceId"
            case memberID = "memberId"
            case agentConfigID = "agentConfigId"
            case channels
        }
        
        public struct Channel: Codable {
            public var id: String
            public var name: String
            public var type: ChannelType
            
            public enum ChannelType: String, Codable {
                case personal, team
            }
        }
    }
    
    struct ConversationConfig: Codable {
        var conversationID: String
        
        enum CodingKeys: String, CodingKey {
            case conversationID = "conversationId"
        }
    }
    
    // Start Conversation
    func startConversation(payload: StartConversationPayload) async throws -> String {
        let res: SocketResponse<[ConversationConfig]>? = try await self.socket?.send(.startConversationInWorkspace, payload: payload)
        struct ConversationIDInvalidError: Error {}
        guard let conversationID = res?.first?.results.first?.conversationID else { throw ConversationIDInvalidError() }
        return conversationID
    }
    
    // Sync Conversation
    func syncConversation(payload: ConversationConfig) async throws -> AIAgentConversationSession {
        guard let socket = self.socket else { throw AIAgentSocketError.socketNil }
        let res: SocketResponse<[AIAgentConversationSession]> = try await socket.send(.syncConversation, payload: payload)
        struct InvalidResponseData: Error {}
        guard let session =  res.first?.results.first else { throw InvalidResponseData() }
        return session
    }
    
    // New Message
    struct NewMessagePayload: Codable {
        var conversationID: AIAgentConversationSession.ID
        var message: AIAgentConversationSession.Message
        var conversationType: AIAgentConversationSession.ConversationType
        
        enum CodingKeys: String, CodingKey {
            case conversationID = "conversationId"
            case message
            case conversationType
        }
    }
    func newMessage<Results: Codable>(payload: NewMessagePayload) async throws -> Results {
        guard let socket = self.socket else { throw AIAgentSocketError.socketNil }
        let res: SocketResponse<Results> = try await socket.send(.newMessage, payload: payload)
        guard let response = res.first else { throw SocketError.responseTypeError }
        return response.results
    }
    
    // Execute tool config
    struct ExecuteToolConfigPayload: Codable {
        var toolConfigID: String
        var toolInput: String
        
        enum CodingKeys: String, CodingKey {
            case toolConfigID = "toolConfigId"
            case toolInput
        }
    }
    func executeToolConfig(payload: ExecuteToolConfigPayload) async throws -> String {
        guard let socket = self.socket else { throw AIAgentSocketError.socketNil }
        let res: SocketResponse<[String]> = try await socket.send(.executeToolConfig, payload: payload)
        return res.first?.results.first ?? ""
    }
    
    // Clear Messages
    func clearMessages(payload: ConversationConfig) async throws {
        guard let socket = self.socket else { throw AIAgentSocketError.socketNil }
        try await socket.send(.clearMessages, payload: payload)
    }
}

// MARK: - Message Handlers
extension TrickleAIAgentSocketClient {
    public typealias SocketResponse<Results: Codable> = [SocketResponseUnit<Results>]
    public struct SocketResponseUnit<Results: Codable>: Codable {
        var results: Results
    }
    public typealias SocketMessageResponse<T: Codable> = [SocketMessageResponseUnit<T>]
    public struct SocketMessageResponseUnit<T: Codable>: Codable {
        var arguments: [T]
    }
    
    enum IncomingSocketEvent: String {
        case updateMessage
    }
    
    public struct MessageResponseData: Codable {
        var replyToMessageID: AIAgentConversationSession.Message.ID
        var messages: [AIAgentConversationSession.Message]
        
        enum CodingKeys: String, CodingKey {
            case replyToMessageID = "replyToMessageId"
            case messages
        }
    }
    
    public enum IncomingMessage {
        case updateMessage(SocketMessageResponse<MessageResponseData>)
    }
    
    func onExternalMessage() {
        let decoder = JSONDecoder()
        
        // updateMessage
        _ = self.socket?.on(.updateMessage) { res, ack in
            do {
                let data = try JSONSerialization.data(withJSONObject: res)
                let response = try decoder.decode(SocketMessageResponse<MessageResponseData>.self,
                                                  from: data)
                Task { await self.onEvents(.updateMessage(response)) }
            } catch {
                dump(error)
                self.logger.error("\(error)", type: "onExternalMessage")
            }
        }
    }
}

public extension TrickleAIAgentSocketClient {
    enum AIAgentSocketError: LocalizedError {
        case socketNil
        
        public var errorDescription: String {
            switch self {
                case .socketNil:
                    return "Socket is nil"
            }
        }
    }
}


fileprivate extension SocketIOClient {
    func emit(_ event: TrickleAIAgentSocketClient.SocketEvent, items: SocketData...) {
        self.emit(event.rawValue, items)
    }
    
    func emitWithAck(_ event: TrickleAIAgentSocketClient.SocketEvent, items: SocketData...) -> OnAckCallback {
        self.emitWithAck(event.rawValue, items)
    }
    
    func on(_ event: TrickleAIAgentSocketClient.IncomingSocketEvent,
            callback: @escaping NormalCallback) -> UUID {
        self.on(event.rawValue, callback: callback)
    }
    
    func send<P: Codable, R: Codable>(
        _ event: TrickleAIAgentSocketClient.SocketEvent,
        payload: P = TrickleAIAgentSocketClient.EmptyData()
    ) async throws -> R {
        return try await withCheckedThrowingContinuation { continuation in
            self.emitWithAck(event,
                             items: ["arguments": [payload.dictionary]])
                .timingOut(after: 10) { res in
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .secondsSince1970
                        
                        let data = try JSONSerialization.data(withJSONObject: res)
                        let decoded = try decoder.decode(R.self, from: data)
                        continuation.resume(with: .success(decoded))
                    } catch {
                        continuation.resume(throwing: error)
                        dump(error)
                    }
                }
        }
    }
    
    func send<P: Codable>(_ event: TrickleAIAgentSocketClient.SocketEvent, payload: P = TrickleAIAgentSocketClient.EmptyData()) async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.emitWithAck(event,
                             items: ["arguments": [payload.dictionary]])
            .timingOut(after: 10) { res in
                continuation.resume()
            }
        }
    }
}
