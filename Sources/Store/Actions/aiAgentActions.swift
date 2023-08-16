//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/7/15.
//

import Foundation
import TrickleCore
import Combine

extension TrickleStoreError {
    public enum AIAgentError: LocalizedError {
        case invalidConversationID(String?)
        case emptyConversationSession
        
        public var errorDescription: String {
            switch self {
                case .invalidConversationID(let id):
                    return "invalid conversation id: \(id ?? "nil")"
                case .emptyConversationSession:
                    return "no conversation session"
            }
        }
    }
}

extension TrickleStore {
    public struct AIAgentState {
        public var agents: [AIAgentData] = []
        public var conversationID: String? = nil
        public var conversationSession: AIAgentConversationSession? = nil
        public var updateMessagePublisher = PassthroughSubject<Void, Never>()
        var messageHelper = AIStateMessageHelper()
    }
    
    
    internal class AIStateMessageHelper {
        var timers: [String : Timer] = [:]
        var actionsQueue: [String : () -> Void] = [:]
        
        func throttle(_ id: AIAgentConversationSession.Message.ID, action: @escaping () -> Void) {
//            print("[throttle] call throttle \(id)")
            self.actionsQueue[id] = action
            if self.timers[id] == nil {
                self.timers[id] = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer in
//                    print("[throttle] timer fired \(id) - \(Date.now.timeIntervalSince1970)")
                    
                    guard let action = self.actionsQueue.removeValue(forKey: id) else {
//                        print("[throttle] not finding action \(id), invalidate timer")
                        self.timers[id]?.invalidate()
                        self.timers.removeValue(forKey: id)
                        return
                    }
//                    print("[throttle] perform action \(id)")
                    action()
                })
                self.timers[id]?.fire()
            }
        }
    }
}

public extension TrickleStore {
    @MainActor
    func onAIAgentSocketEvents(_ event: TrickleAIAgentSocketClient.IncomingMessage) async {
        switch event {
            case .updateMessage(let res):
                // Everytime user send a message to AI, the server will response the user
                // sended message firstly to update the local one. The `messageID` will be
                // the smae as the `replyToMessageID`.
                // Then, real AI messages will be replied with multiple times but with a
                // same `messageID`. The `replyToMessageID` will keep the origin value.
                // At the end of this stream, a updated user sended message will be replied
                // so that we can update some properties such as `status`.
                for message in res {
                    for data in message.arguments {
                        for message in data.messages {
                            updateAIAgentMessage(message)
                        }
                    }
                }
                break
        }
    }
    
    func establishAIAgentSocket(force: Bool = false, onConnected: (() -> Void)?) {
        guard let token = self.userInfo.value??.token else { return }
        if self.aiAgentSocket.socket?.status == .connected && !force {
            return
        }
        self.aiAgentSocket.conntect(token: token, onConnected: onConnected)
    }
    
    func listPublishedAgentConfigs() async {
        do {
            let agents = try await self.aiAgentSocket.listPublishedAgentConfigs()
            self.aiAgentState.agents = agents
        } catch {
            self.error = .init(error)
        }
    }
    
    func startAIAgentConversation(workspaceID: WorkspaceData.ID, memberID: MemberData.ID, agentConfigID: AIAgentData.ID) async {
        do {
            self.aiAgentState.conversationID = nil
            let conversationID = try await self.aiAgentSocket.startConversation(payload: .init(workspaceID: workspaceID, memberID: memberID, agentConfigID: agentConfigID))
            self.aiAgentState.conversationID = conversationID
        } catch {
            self.error = .init(error)
        }
    }
    
    func syncAIAgentConversation() async {
        do {
            guard let conversationID = self.aiAgentState.conversationID else {
                throw TrickleStoreError.aiAgentError(.invalidConversationID(nil))
            }
            let session = try await self.aiAgentSocket.syncConversation(payload: .init(conversationID: conversationID))
            self.aiAgentState.conversationSession = session
        } catch {
            self.error = .init(error)
        }
    }
    
    func sendMessageToAIAgent(_ message: AIAgentConversationSession.Message) async {
        do {
            guard let conversationID = self.aiAgentState.conversationID else {
                throw TrickleStoreError.aiAgentError(.invalidConversationID(nil))
            }
            
            guard self.aiAgentState.conversationSession != nil else {
                throw TrickleStoreError.aiAgentError(.emptyConversationSession)
            }
            self.aiAgentState.conversationSession?.messages.append(message)
            try await self.aiAgentSocket.newMessage(payload: .init(conversationID: conversationID, message: message))
        } catch {
            self.error = .init(error)
            setAIAgentMessageAsFailed(message.messageID)
        }
    }
    
    func clearAIAgentMessages() async {
        let backup = self.aiAgentState.conversationSession?.messages ?? []
        do {
            guard let conversationID = self.aiAgentState.conversationID else {
                throw TrickleStoreError.aiAgentError(.invalidConversationID(nil))
            }
            self.aiAgentState.conversationSession?.messages.removeAll()
            try await self.aiAgentSocket.clearMessages(payload: .init(conversationID: conversationID))
        } catch {
            self.error = .init(error)
            self.aiAgentState.conversationSession?.messages = backup
        }
    }
}


public extension TrickleStore {
    func setAIAgentMessageAsFailed(_ id: AIAgentConversationSession.Message.ID) {
        guard let index = self.aiAgentState.conversationSession?.messages.firstIndex(where: {$0.messageID == id}) else {
            return
        }
        self.aiAgentState.conversationSession?.messages[index].status = .error
    }
    
    /// update a `AIAgentConversationSession.Message`, or creating a new one if not exist.
    func updateAIAgentMessage(_ message: AIAgentConversationSession.Message) {
        if let index = self.aiAgentState.conversationSession?.messages.firstIndex(where: {
            $0.messageID == message.messageID
        }) {
            self.aiAgentState.messageHelper.throttle(message.messageID) {
                self.aiAgentState.conversationSession?.messages[index] = message
                DispatchQueue.main.async {
                    self.aiAgentState.updateMessagePublisher.send()
                }
            }
        } else {
            self.aiAgentState.conversationSession?.messages.append(message)
        }
    }
}
