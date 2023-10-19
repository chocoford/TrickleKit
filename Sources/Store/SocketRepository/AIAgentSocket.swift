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
        guard log else { return }
        let msg = message()
        logger.log("\(type, privacy: .public): \(msg, privacy: .public)")
    }
    
    func error(_ message: @autoclosure () -> String, type: String) {
        guard log else { return }
        let msg = message()
        logger.error("\(type, privacy: .public): \(msg, privacy: .public)")
    }
    
    func debug(_ message: String) {
        guard log else { return }
        logger.debug("\(message, privacy: .public)")
    }
    
    func info(_ message: String) {
        guard log else { return }
        logger.info("\(message, privacy: .public)")
    }
}

public final class TrickleAIAgentSocketClient {
    public internal(set) var socketManager: SocketManager? = nil
    public internal(set) var socket: SocketIOClient? = nil
    
    @Published
    public var status: Status = .disconnected
    
    var onEvents: (IncomingMessage) async -> Void = { _ in }
        
    public init() { }
    
    let logger: TrickleAIAgentSocketLogger = .init()
    
    func configSocket(token: String, log: Bool = false) {
        let url = URL(string: "https://\(TrickleEnv.aiActionDomain)")!
        self.socketManager = SocketManager(socketURL: url,
                                    config: [
                                        .logger(logger),
                                        .log(log),
                                        .compress,
                                        .connectParams(["token" : "Bearer \(token)"]),
                                        .path("/trickleai-sio"),
                                        .secure(true),
                                        .forceWebsockets(true)
                                    ])
        
        self.socket = self.socketManager?.defaultSocket
        
        self.socket?.on(clientEvent: .connect) {data, ack in
            self.logger.debug("socket connected")
            self.status = .connected
        }
        self.socket?.on(clientEvent: .error) {data, ack in
            self.logger.debug("socket connect error: \(data)")
            self.status = .error
        }
        self.socket?.on(clientEvent: .reconnect) {data, ack in
            self.logger.debug("socket reconnecting...")
            self.status = .reconnecting
        }
        self.socket?.on(clientEvent: .statusChange) {data, ack in
            self.logger.debug("socket status changed: \(data)")
        }
        self.socket?.on(clientEvent: .disconnect) {data, ack in
            self.logger.debug("socket status disconnected: \(data)")
            self.status = .disconnected
        }
        self.socket?.on(clientEvent: .websocketUpgrade) {data, ack in
            self.logger.debug("socket websocketUpgraded: \(data)")
        }
        
        self.socket?.connect()
        self.onExternalMessage()
    }
}

public extension TrickleAIAgentSocketClient {
    func conntect(token: String, log: Bool = false) {
        configSocket(token: token, log: log)
    }
    
    func disconnect() {
        self.socket?.disconnect()
    }
}


// MARK: - Public API
public extension TrickleAIAgentSocketClient {
    enum Status: CustomStringConvertible {
        case connected, disconnected, reconnecting
        case error
        
        public var description: String {
            switch self {
                case .connected:
                    "Connected"
                case .disconnected:
                    "Disconnected"
                case .reconnecting:
                    "Reconnecting"
                case .error:
                    "Error"
            }
        }
    }
    
    enum SocketError: LocalizedError {
        case responseTypeError
        
        public var errorDescription: String? {
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
        case listConversationMessages
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
    
    struct ListConversationMessagesConfig: Codable {
        var until: String?
        var limit: Int
        var conversationID: String?
        var type: ListType
        
        enum CodingKeys: String, CodingKey {
            case until, limit, type
            case conversationID = "conversationId"
        }
        
        enum ListType: String, Codable {
            case chat, memory, capture
        }
    }
    struct ListConversationMessagesResponseData: Codable {
        var messages: [AIAgentConversationSession.Message]
    }
    func listConversationMessages(payload: ListConversationMessagesConfig) async throws -> ListConversationMessagesResponseData {
        guard let socket = self.socket else { throw AIAgentSocketError.socketNil }
        let res: SocketResponse<[ListConversationMessagesResponseData]> = try await socket.send(.listConversationMessages, payload: payload)
        struct InvalidResponseData: Error {}
        guard let session =  res.first?.results.first else { throw InvalidResponseData() }
        return session
    }
    
    // New Message
    struct NewMessagePayload: Codable {
        public var conversationID: AIAgentConversationSession.ID
        public var message: AIAgentConversationSession.Message
        public var conversationType: AIAgentConversationSession.ConversationType
        public var workspaceID: WorkspaceData.ID
        public var groupID: GroupData.ID
        public var isTeamGroup: Bool
        
        enum CodingKeys: String, CodingKey {
            case conversationID = "conversationId"
            case message
            case conversationType
            case workspaceID = "workspaceId"
            case groupID = "channelId"
            case isTeamGroup = "isTeamChannel"
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
        payload: P = TrickleAIAgentSocketClient.EmptyData(),
        timeout: Double = 30
    ) async throws -> R {
        return try await withCheckedThrowingContinuation { continuation in
            self.emitWithAck(event,
                             items: ["arguments": [payload.dictionary]])
                .timingOut(after: timeout) { res in
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .secondsSince1970
                        
                        let data = try JSONSerialization.data(withJSONObject: res)
                        do {
                            let decoded = try decoder.decode(R.self, from: data)
                            continuation.resume(with: .success(decoded))
                        } catch {
#if DEBUG
//                            print(String(data: data, encoding: .utf8) ?? "")
                            dump(error, name: "Decode error")
#endif
                            throw error
                        }
                    } catch {
                        continuation.resume(throwing: error)
//                        logger.error("\(error.localizedDescription)")
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
