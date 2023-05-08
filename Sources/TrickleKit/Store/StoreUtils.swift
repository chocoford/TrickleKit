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
    func findTrickleGroup(_ trickleID: TrickleData.ID) -> GroupData? {
        if trickleID == currentTrickleID { return currentGroup }
        guard let theGroupTrickles = groupsTrickles.first(where: { key, value in
            value.contains(where: { trickle in
                trickle.trickleID == trickleID
            }) == true
        }) else { return nil }
        return groups[theGroupTrickles.key]
    }
    
    func findViewGroup(_ viewID: GroupData.ViewInfo.ID) -> GroupData? {
        if viewID == currentGroupViewID {
            return currentGroup
        }
        
        return groups.values.first(where: { group in
            group.viewInfo.contains { $0.viewID == viewID }
        })
    }
    
    func findGroupWorkspace(_ groupID: GroupData.ID) -> WorkspaceData? {
        if groupID == currentGroupID {
            return currentWorkspace
        }
        guard let theWorkspaceGroups = workspacesGroups.first(where: { key, value in
            value.value?.team.contains(where: { $0.groupID == groupID }) == true || value.value?.personal.contains(where: { $0.groupID == groupID }) == true
        }) else { return nil }
        return workspaces[theWorkspaceGroups.key]
    }
    
    func findTrickleWorkspace(_ trickleID: TrickleData.ID) throws -> WorkspaceData {
        guard let group = findTrickleGroup(trickleID) else { throw TrickleStoreError.FindingError.trickleGroupNotFound(trickleID) }
        guard let workspace = findGroupWorkspace(group.groupID) else { throw TrickleStoreError.FindingError.groupWorkspaceNotFound(group.groupID) }
        return workspace
    }
}

