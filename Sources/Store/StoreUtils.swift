//
//  StoreUtils.swift
//  
//
//  Created by Chocoford on 2023/5/2.
//

import SwiftUI
import TrickleCore

public extension TrickleStoreError {
    enum FindingError: LocalizedError {
        case trickleGroupNotFound(_ trickleID: TrickleData.ID)
        case groupWorkspaceNotFound(_ groupID: GroupData.ID)
        
        public var errorDescription: String? {
            switch self {
                case .trickleGroupNotFound(let trickleID):
                    return "The group corresponding to the trickle(\(trickleID)) can not be found."
                case .groupWorkspaceNotFound(let groupID):
                    return "The workspace corresponding to the group(\(groupID)) can not be found."
            }
        }
    }
}

public extension TrickleStore {
    func findTrickleGroup(_ trickleID: TrickleData.ID?) throws -> GroupData {
        guard let trickleID = trickleID else { throw TrickleStoreError.invalidTrickleID(trickleID) }
        if trickleID == currentTrickleID, let group = currentGroup { return group }
        guard let trickleData = trickles[trickleID] else { throw TrickleStoreError.invalidTrickleID(trickleID) }
        guard let groupID = trickleData.groupInfo.groupID, let groupData = groups[groupID] else {
            throw TrickleStoreError.invalidGroupID(trickleData.groupInfo.groupID)
        }
        return groupData
    }

//    func findTrickleGroup(_ trickleID: TrickleData.ID) -> GroupData? {
//        if trickleID == currentTrickleID { return currentGroup }
//        guard let theGroupTrickles = groupsTrickles.first(where: { key, value in
//            value.contains(where: { trickle in
//                trickle.trickleID == trickleID
//            }) == true
//        }) else { return nil }
//        return groups[theGroupTrickles.key]
//    }
    
    func findViewGroup(_ viewID: GroupData.ViewInfo.ID?) throws -> GroupData {
        guard let viewID = viewID else { throw TrickleStoreError.invalidViewID(viewID) }
        if viewID == currentGroupViewID, let group = currentGroup {
            return group
        }
        if let group = groups.values.first(where: { group in
            group.viewInfo.contains { $0.viewID == viewID }
        }) {
            return group
        } else {
            throw TrickleStoreError.invalidViewID(viewID)
        }
        
    }
    
    func findGroupWorkspace(_ groupID: GroupData.ID?) throws -> WorkspaceData {
        guard let groupID = groupID else { throw TrickleStoreError.invalidGroupID(groupID) }
        guard let theWorkspaceGroups = workspacesGroups.first(where: { key, value in
            value.value?.team.contains(where: { $0.groupID == groupID }) == true || value.value?.personal.contains(where: { $0.groupID == groupID }) == true
        }) else { throw TrickleStoreError.invalidGroupID(groupID) }
        if let workspace = workspaces[theWorkspaceGroups.key] {
            return workspace
        } else {
            throw TrickleStoreError.invalidWorkspaceID(theWorkspaceGroups.key)
        }
    }
    
    func findTrickleWorkspace(_ trickleID: TrickleData.ID?) throws -> WorkspaceData {
        do {
            let group = try findTrickleGroup(trickleID)
            let workspace = try findGroupWorkspace(group.groupID)
            return workspace
        } catch let error as TrickleStoreError {
            if case .invalidGroupID(let groupID) = error, groupID == nil, let trickleID = trickleID {
                return try findMemberWorkspace(self.trickles[trickleID]?.authorMemberInfo.memberID)
            }
            throw error
        } catch {
            throw error
        }
    }
    
    func findViewWorkspace(_ viewID: GroupData.ViewInfo.ID?) throws -> WorkspaceData {
        let group = try findViewGroup(viewID)
        let workspace = try findGroupWorkspace(group.groupID)
        return workspace
    }
    
    func findMemberWorkspace(_ memberID: MemberData.ID?) throws -> WorkspaceData {
        guard let memberID = memberID,
              let workspaceID = workspacesMembers.first(where: {
            $0.value.value?.items.contains(where: {$0.memberID == memberID}) == true
        })?.key else { throw TrickleStoreError.invalidMemberID(memberID) }
        guard let workspace = self.workspaces[workspaceID] else { throw TrickleStoreError.invalidWorkspaceID(workspaceID) }
        return workspace
    }
}

