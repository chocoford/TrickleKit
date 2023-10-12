//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/7/15.
//

import Foundation
import ChocofordEssentials
import TrickleCore
import Combine

extension TrickleStoreError {
    public enum AIAgentError: LocalizedError {
        case invalidConversationID(String?)
        case emptyConversationSession
        
        public var errorDescription: String? {
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
        public typealias ConversationID = String
        
        public var agents: [AIAgentData] = []
        public var conversationIDs: [AIAgentData.ID : ConversationID] = [:]
        public var conversationMessages: [AIAgentData.ID : Loadable<[AIAgentConversationSession.Message]>] = [:]
        public var hasMoreConversationMessages: [AIAgentData.ID : Bool] = [:]
        public var updateMessagePublisher = PassthroughSubject<Void, Never>()
        var messageHelper = AIStateMessageHelper()
        
        func getAgentConfigID(with conversationID: ConversationID) -> AIAgentData.ID? {
            conversationIDs.first {
                $0.value == conversationID
            }?.key
        }
        
        public var hasMoreCaptureAgentMessages: Bool? { hasMoreConversationMessages[TrickleEnv.captureAgentID] }
        public var captureAgentMessages: Loadable<[AIAgentConversationSession.Message]> {
            conversationMessages[TrickleEnv.captureAgentID] ?? .notRequested
        }
    }
    
    
    internal class AIStateMessageHelper {
        var timers: [String : Timer] = [:]
        var actionsQueue: [String : () -> Void] = [:]
        
        func throttle(_ id: AIAgentConversationSession.Message.ID, action: @escaping () -> Void) {
//            print("[throttle] call throttle \(id)")
            self.actionsQueue[id] = action
            if self.timers[id] == nil {
                self.timers[id] = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true, block: { timer in
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
    
    func establishAIAgentSocket(force: Bool = false, log: Bool = false) {
        guard let token = self.userInfo.value??.token else { return }
        if self.aiAgentSocket.socket?.status == .connected && !force {
            return
        }
        self.aiAgentSocket.conntect(token: token, log: log)
    }
    
    func listPublishedAgentConfigs() async {
        do {
            let agents = try await self.aiAgentSocket.listPublishedAgentConfigs()
            self.aiAgentState.agents = agents
        } catch {
            self.error = .init(error)
        }
    }

    func tryStartAIAgentConversation(workspaceID: WorkspaceData.ID, memberID: MemberData.ID, agentConfigID: AIAgentData.ID, groups: [GroupData]) async throws {
        self.aiAgentState.conversationIDs.removeValue(forKey: agentConfigID)
        let conversationID = try await self.aiAgentSocket.startConversation(
            payload: .init(
                workspaceID: workspaceID,
                memberID: memberID,
                agentConfigID: agentConfigID,
                channels: groups.map {
                    .init(id: $0.groupID, name: $0.name, type: $0.belongTo == "team" ? .team : .personal)
                }
            )
        )
        self.aiAgentState.conversationIDs.updateValue(conversationID, forKey: agentConfigID)
        self.aiAgentState.conversationMessages.updateValue(.loaded(data: []), forKey: agentConfigID)
    }
    
    func startAIAgentConversation(workspaceID: WorkspaceData.ID, memberID: MemberData.ID, agentConfigID: AIAgentData.ID, groups: [GroupData]) async {
        do {
            try await tryStartAIAgentConversation(workspaceID: workspaceID, memberID: memberID, agentConfigID: agentConfigID, groups: groups)
        } catch {
            self.error = .init(error)
        }
    }
    
    @available(*, deprecated, message: "Please use tryLoadMoreConversation")
    func trySyncAIAgentConversation(with agentConfigID: AIAgentData.ID) async throws {
//        guard let conversationID = self.aiAgentState.conversationIDs[agentConfigID] else {
//            throw TrickleStoreError.aiAgentError(.invalidConversationID(nil))
//        }
//        let session = try await self.aiAgentSocket.syncConversation(payload: .init(conversationID: conversationID))
//        self.aiAgentState.conversationSessions.updateValue(.loaded(data: session), forKey: agentConfigID)
    }
    
    @available(*, deprecated, message: "Please use loadMoreConversation")
    func syncAIAgentConversation(with agentConfigID: AIAgentData.ID) async {
        do {
            try await trySyncAIAgentConversation(with: agentConfigID)
        } catch {
            self.error = .init(error)
        }
    }
    
    func tryLoadMoreAIAgentConversation(with agentConfigID: AIAgentData.ID, silent: Bool = false) async throws {
        guard let conversationID = self.aiAgentState.conversationIDs[agentConfigID] else {
            throw TrickleStoreError.aiAgentError(.invalidConversationID(nil))
        }
        if !silent { self.aiAgentState.conversationMessages[agentConfigID]?.setIsLoading() }
        
        let newUntil: String? = if let until = Int(self.aiAgentState.conversationMessages[agentConfigID]?.value?.first?.createAt ?? "0") {
            String(until - 1)
        } else {
             nil
        }
        
        let res = try await self.aiAgentSocket.listConversationMessages(
            payload: .init(until: newUntil,
                           limit: 20,
                           conversationID: conversationID,
                           type: .chat)
        )
        self.aiAgentState.hasMoreConversationMessages.updateValue(res.messages.count >= 20, forKey: agentConfigID)
        self.aiAgentState.conversationMessages[agentConfigID]?.setAsLoaded {
            $0?.insert(contentsOf: res.messages, at: 0)
        }
    }
    
    func loadMoreAIAgentConversation(with agentConfigID: AIAgentData.ID, silent: Bool = false) async {
        do {
            try await tryLoadMoreAIAgentConversation(with: agentConfigID, silent: silent)
        } catch {
            self.error = .init(error)
        }
    }
    
    
    /// Try to send message to ai agent. If message contains a image, it will auto upload to the server.
    func trySendMessageToAIAgent<Results: Codable>(
        to agentConfigID: AIAgentData.ID,
        _ message: AIAgentConversationSession.Message,
        conversationType: AIAgentConversationSession.ConversationType,
        workspaceID: WorkspaceData.ID,
        groupID: GroupData.ID,
        isTeamGroup: Bool
    ) async throws -> Results {
        do {
            guard let conversationID = self.aiAgentState.conversationIDs[agentConfigID] else {
                throw TrickleStoreError.aiAgentError(.invalidConversationID(nil))
            }
            guard self.aiAgentState.conversationMessages[agentConfigID] != nil else {
                throw TrickleStoreError.aiAgentError(.emptyConversationSession)
            }
            
            if let index = self.aiAgentState.conversationMessages[agentConfigID]?.value?.firstIndex(where: {$0.messageID == message.messageID}) {
                self.aiAgentState.conversationMessages[agentConfigID]?.transform {
                    $0[index] = message
                }
            } else {
                self.aiAgentState.conversationMessages[agentConfigID]?.transform {
                    $0.append(message)
                }
            }
            let res: Results = try await self.aiAgentSocket.newMessage(
                payload: .init(
                    conversationID: conversationID,
                    message: message,
                    conversationType: conversationType,
                    workspaceID: workspaceID,
                    groupID: groupID,
                    isTeamGroup: isTeamGroup
                )
            )
            return res
        } catch {
            self.setAIAgentMessageAsFailed(of: agentConfigID, messageID: message.messageID)
            throw error
        }
    }
    
    func sendMessageToAIAgent(to agentConfigID: AIAgentData.ID, 
                              _ message: AIAgentConversationSession.Message,
                              conversationType: AIAgentConversationSession.ConversationType,
                              workspaceID: WorkspaceData.ID,
                              groupID: GroupData.ID,
                              isTeamGroup: Bool) async {
        do {
            struct Restuls: Codable {}
            _ = try await self.trySendMessageToAIAgent(to: agentConfigID, message, conversationType: conversationType,
                                                       workspaceID: workspaceID,
                                                       groupID: groupID,
                                                       isTeamGroup: isTeamGroup) as Restuls?
        } catch {
            self.error = .init(error)
        }
    }
    
    func clearAIAgentMessages(of agentConfigID: AIAgentData.ID) async {
        let backup = self.aiAgentState.conversationMessages[agentConfigID]
        do {
            guard let conversationID = self.aiAgentState.conversationIDs[agentConfigID] else {
                throw TrickleStoreError.aiAgentError(.invalidConversationID(nil))
            }
            self.aiAgentState.conversationMessages[agentConfigID]?.transform {
                $0.removeAll()
            }
            try await self.aiAgentSocket.clearMessages(payload: .init(conversationID: conversationID))
        } catch {
            self.error = .init(error)
            if let backup = backup {
                self.aiAgentState.conversationMessages.updateValue(backup, forKey: agentConfigID)
            }
        }
    }
    
    func executeSummaryTool(input: String) async -> String {
        do {
            return try await self.aiAgentSocket.executeToolConfig(
                payload: .init(toolConfigID: "ad90c53c196844b1b0647d0d7d1835b6", toolInput: input)
            )
        } catch {
            self.error = .init(error)
            return ""
        }
    }
}


public extension TrickleStore {
    func setAIAgentMessageAsFailed(of agentConfigID: AIAgentData.ID, messageID: AIAgentConversationSession.Message.ID) {
        guard let index = self.aiAgentState.conversationMessages[agentConfigID]?.value?.firstIndex(where: {$0.messageID == messageID}) else {
            return
        }
        self.aiAgentState.conversationMessages[agentConfigID]?.transform {
            $0[index].status = .error
        }
    }
    
    /// update a `AIAgentConversationSession.Message`, or creating a new one if not exist.
    func updateAIAgentMessage(_ message: AIAgentConversationSession.Message) {
        guard let agentConfigID = aiAgentState.getAgentConfigID(with: message.conversationID ?? "") else { return }
        if let index = self.aiAgentState.conversationMessages[agentConfigID]?.value?.firstIndex(where: {
               $0.messageID == message.messageID
           }) {
            self.aiAgentState.conversationMessages[agentConfigID]?.transform {
                $0[index] = message
            }
            self.aiAgentState.messageHelper.throttle(message.messageID) {
                DispatchQueue.main.async {
                    self.aiAgentState.updateMessagePublisher.send()
                }
            }
        } else {
            self.aiAgentState.conversationMessages[agentConfigID]?.transform {
                $0.append(message)
            }
        }
    }
}
