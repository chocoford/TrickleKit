//
//  StoreUtils.swift
//  
//
//  Created by Chocoford on 2023/5/2.
//

import SwiftUI

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
    func findTrickleGroup(_ trickleID: TrickleData.ID) throws -> GroupData {
        if trickleID == currentTrickleID, let group = currentGroup { return group }
        guard let trickleData = trickles[trickleID] else { throw TrickleStoreError.invalidTrickleID(trickleID) }
        guard let groupData = groups[trickleData.groupInfo.groupID] else { throw TrickleStoreError.invalidGroupID(trickleData.groupInfo.groupID) }
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
    
    func findViewGroup(_ viewID: GroupData.ViewInfo.ID) throws -> GroupData {
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
    
    func findGroupWorkspace(_ groupID: GroupData.ID) throws -> WorkspaceData {
        if groupID == currentGroupID, let workspace = currentWorkspace {
            return workspace
        }
        guard let theWorkspaceGroups = workspacesGroups.first(where: { key, value in
            value.value?.team.contains(where: { $0.groupID == groupID }) == true || value.value?.personal.contains(where: { $0.groupID == groupID }) == true
        }) else { throw TrickleStoreError.invalidGroupID(groupID) }
        if let workspace = workspaces[theWorkspaceGroups.key] {
            return workspace
        } else {
            throw TrickleStoreError.invalidWorkspaceID(theWorkspaceGroups.key)
        }
    }
    
    func findTrickleWorkspace(_ trickleID: TrickleData.ID) throws -> WorkspaceData {
        let group = try findTrickleGroup(trickleID) 
        let workspace = try findGroupWorkspace(group.groupID)
        return workspace
    }
}

