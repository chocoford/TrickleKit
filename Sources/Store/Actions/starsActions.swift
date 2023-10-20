//
//  File.swift
//  
//
//  Created by Chocoford on 2023/5/2.
//

import Foundation
import ChocofordEssentials
import TrickleCore

public extension TrickleStoreError {
    enum StarError: LocalizedError {
        case alreadyStarred
        case alreadyUnstarred
        
        public var errorDescription: String? {
            switch self {
                case .alreadyStarred:
                    return "The trickle is already starred."
                    
                case .alreadyUnstarred:
                    return "The trickle is already unstarred."
            }
        }
    }
}

public extension TrickleStore {
    func listStarredTrickles(workspaceID: WorkspaceData.ID, memberID: MemberData.ID) async {
        do {
            self.starredTrickleIDs[workspaceID]?.setIsLoading()
            let data = try await webRepositoryClient.listTrickles(workspaceID: workspaceID,
                                                                  query: .init(memberID: memberID, starredByMemberID: memberID))
            
            self.starredTrickleIDs[workspaceID] = .loaded(data: data.map{$0.trickleID})
        } catch {
            self.error = .init(error)
            self.starredTrickleIDs[workspaceID]?.setAsFailed(error)
        }
    }
    
    func tryStarTrickle(trickleID: TrickleData.ID) async throws {
        guard trickles[trickleID]?.hasStarred == false else { throw TrickleStoreError.starError(.alreadyStarred) }
        let workspace = try findTrickleWorkspace(trickleID)
        do {
            trickles[trickleID]?.hasStarred = true
            _ = try await webRepositoryClient.starTrickle(workspaceID: workspace.workspaceID,
                                                          trickleID: trickleID,
                                                          payload: .init(memberID: workspace.userMemberInfo.memberID))
        } catch {
            trickles[trickleID]?.hasStarred = false
            throw error
        }
    }
    
    func starTrickle(trickleID: TrickleData.ID) async {
        do {
            try await tryStarTrickle(trickleID: trickleID)
        } catch {
            self.error = .init(error)
        }
    }
    
    func tryUnstarTrickle(trickleID: TrickleData.ID) async throws {
        guard trickles[trickleID]?.hasStarred == true else { throw TrickleStoreError.starError(.alreadyUnstarred) }
        let workspace = try findTrickleWorkspace(trickleID)

        do {
            trickles[trickleID]?.hasStarred = false
            _ = try await webRepositoryClient.unstarTrickle(workspaceID: workspace.workspaceID, trickleID: trickleID, payload: .init(memberID: workspace.userMemberInfo.memberID))
        } catch {
            trickles[trickleID]?.hasStarred = true
        }
    }
    
    func unstarTrickle(trickleID: TrickleData.ID) async {
        do {
            try await tryUnstarTrickle(trickleID: trickleID)
        } catch {
            self.error = .init(error)
        }
    }
}

//extension TrickleStore {
//    func setTrickleAsStarred(_ trickleID: TrickleData.ID) {
//        trickles[trickleID]?.hasStarred = true
//    }
//    func setTrickleAsStarred(_ trickleID: TrickleData.ID) {
//        trickles[trickleID]?.hasStarred = true
//    }
//}
