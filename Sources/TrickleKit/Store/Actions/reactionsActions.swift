//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/6.
//

import Foundation

extension TrickleStore {
    public func tryCreateReaction(to trickleID: TrickleData.ID, emoji: String) async throws {
        guard let theTrickle = trickles[trickleID] else { throw TrickleStoreError.invalidTrickleID(trickleID) }
        let theWorkspace = try findGroupWorkspace(theTrickle.groupInfo.groupID)

        let mockID = UUID().uuidString
        let mockReaction: ReactionData = ReactionData(reactionID: mockID,
                                                      code: emoji,
                                                      createAt: .now,
                                                      updateAt: .now,
                                                      reactionAuthor: theWorkspace.userMemberInfo)
        
        addReaction(mockReaction, to: trickleID)
    
        do {
            let data = try await webRepositoryClient.createTrickleReaction(workspaceID: theWorkspace.workspaceID,
                                                                           trickleID: trickleID,
                                                                           payload: .init(memberID: theWorkspace.userMemberInfo.memberID,
                                                                                          reactionCode: emoji))
            
            modifyReaction(from: mockReaction, to: data, of: trickleID)
        } catch {
            _ = try? removeReaction(reactionID: mockReaction.reactionID, from: trickleID)
            throw error
        }
    }
    
    public func createReaction(to trickleID: TrickleData.ID, emoji: String) async {
        do {
            try await tryCreateReaction(to: trickleID, emoji: emoji)
        } catch {
            self.error = .init(error)
        }
    }
    
    public func tryDeleteReaction(of trickleID: TrickleData.ID, reactionData: ReactionData) async throws {
        guard let theTrickle = trickles[trickleID] else { throw TrickleStoreError.invalidTrickleID(trickleID) }
        let theWorkspace = try findGroupWorkspace(theTrickle.groupInfo.groupID)
        
        let index = try removeReaction(reactionID: reactionData.reactionID, from: trickleID)
        do {
            _ = try await webRepositoryClient.deleteTrickleReaction(workspaceID: theWorkspace.workspaceID,
                                                                    trickleID: trickleID,
                                                                    reactionID: reactionData.reactionID,
                                                                    payload: .init(memberID: theWorkspace.userMemberInfo.memberID))
        } catch {
            self.error = .init(error)
            addReaction(reactionData, to: trickleID, at: index)
        }
    }
    
    public func deleteReaction(of trickleID: TrickleData.ID, reactionData: ReactionData) async {
        do {
            try await tryDeleteReaction(of: trickleID, reactionData: reactionData)
        } catch {
            self.error = .init(error)
        }
    }
}

// MARK: - Sync change
extension TrickleStore {
    func addReaction(_ reaction: ReactionData, to trickleID: TrickleData.ID, at index: Int? = nil) {
        guard trickles[trickleID]?.reactionInfo.contains(reaction) != true else { return }
        if let index = index {
            trickles[trickleID]?.reactionInfo.insert(reaction, at: index)
        } else {
            trickles[trickleID]?.reactionInfo.append(reaction)
        }
    }
    
    func modifyReaction(from source: ReactionData, to target: ReactionData, of trickleID: TrickleData.ID) {
        guard let index = trickles[trickleID]?.reactionInfo.firstIndex(of: source) else { return }
        trickles[trickleID]?.reactionInfo[index] = target
    }
    
    func removeReaction(reactionID: ReactionData.ID, from trickleID: TrickleData.ID) throws -> Int {
        guard let index = trickles[trickleID]?.reactionInfo.firstIndex(where: {$0.reactionID == reactionID}) else { throw TrickleStoreError.invalidReactionID(reactionID) }
        trickles[trickleID]?.reactionInfo.removeAll {
            $0.reactionID == reactionID
        }
        return index
    }
    
    func addCommentReaction(_ reaction: ReactionData, to commentID: CommentData.ID, at index: Int? = nil) {
        if comments[commentID]?.reactionInfo?.contains(reaction) != true { return }
        if (comments[commentID]?.reactionInfo == nil) {
            comments[commentID]?.reactionInfo = []
        }
        if let index = index {
            comments[commentID]?.reactionInfo?.insert(reaction, at: index)
        } else {
            comments[commentID]?.reactionInfo?.append(reaction)
        }
    }
    
    func modifyCommentReaction(from source: ReactionData, to target: ReactionData, of commentID: CommentData.ID) {
        guard let index = comments[commentID]?.reactionInfo?.firstIndex(of: source) else { return }
        comments[commentID]?.reactionInfo?[index] = target
    }
    
    func removeCommentReaction(reactionID: ReactionData.ID, from commentID: CommentData.ID) throws -> Int {
        guard let index = comments[commentID]?.reactionInfo?.firstIndex(where: {$0.reactionID == reactionID}) else { throw TrickleStoreError.invalidReactionID(reactionID) }
        comments[commentID]?.reactionInfo?.removeAll {
            $0.reactionID == reactionID
        }
        return index
    }
}
