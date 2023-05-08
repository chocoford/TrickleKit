//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/6.
//

import Foundation

extension TrickleStore {
    public func addReaction(to trickleID: TrickleData.ID?, emoji: String) async {
        guard let trickleID = trickleID ?? currentTrickleID else { return }
        
        guard let theTrickle = trickles[trickleID],
              let theWorkspace = findGroupWorkspace(theTrickle.groupInfo.groupID) else { return }
        
        let mockID = UUID().uuidString
        let mockReaction: ReactionData = ReactionData(code: emoji,
                                                      createAt: .now,
                                                      updateAt: .now,
                                                      reactionID: mockID,
                                                      reactionAuthor: theWorkspace.userMemberInfo)
        trickles[trickleID]?.reactionInfo.append(mockReaction)
        
        do {
            let data = try await webRepositoryClient.createTrickleReaction(workspaceID: theWorkspace.workspaceID,
                                                                           trickleID: trickleID,
                                                                           payload: .init(memberID: theWorkspace.userMemberInfo.memberID,
                                                                                          reactionCode: emoji))
            
            if let mockIndex = trickles[trickleID]?.reactionInfo.firstIndex(of: mockReaction) {
                trickles[trickleID]?.reactionInfo.remove(at: mockIndex)
                trickles[trickleID]?.reactionInfo.insert(data, at: mockIndex)
            }
        } catch let error as LoadableError {
            self.error = .lodableError(error)
            if let mockIndex = trickles[trickleID]?.reactionInfo.firstIndex(of: mockReaction) {
                trickles[trickleID]?.reactionInfo.remove(at: mockIndex)
            }
        } catch {
            self.error = .unexpected(error)
            if let mockIndex = trickles[trickleID]?.reactionInfo.firstIndex(of: mockReaction) {
                trickles[trickleID]?.reactionInfo.remove(at: mockIndex)
            }
        }
    }
    public func removeReaction(of trickleID: String?, reactionData: ReactionData) async {
        guard let trickleID = trickleID ?? currentTrickleID else { return }
        
        guard let theTrickle = trickles[trickleID],
              let theWorkspace = findGroupWorkspace(theTrickle.groupInfo.groupID) else { return }
        
        let index = trickles[trickleID]?.reactionInfo.firstIndex(of: reactionData)
        if let index = index {
            trickles[trickleID]?.reactionInfo.remove(at: index)
        }
        
        do {
            _ = try await webRepositoryClient.deleteTrickleReaction(workspaceID: theWorkspace.workspaceID,
                                                                    trickleID: trickleID,
                                                                    reactionID: reactionData.reactionID,
                                                                    payload: .init(memberID: theWorkspace.userMemberInfo.memberID))
        } catch let error as LoadableError {
            self.error = .lodableError(error)
            if let index = index {
                trickles[trickleID]?.reactionInfo.insert(reactionData, at: index)
            }
        } catch {
            self.error = .unexpected(error)
            if let index = index {
                trickles[trickleID]?.reactionInfo.insert(reactionData, at: index)
            }
        }
    }
}
