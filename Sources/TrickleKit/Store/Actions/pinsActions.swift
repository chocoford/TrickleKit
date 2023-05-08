//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/6.
//

import Foundation

public extension TrickleStoreError {
    enum PinError: LocalizedError {
        case alreadyPinned
        case alreadyUnpinned
        
        public var errorDescription: String? {
            switch self {
                case .alreadyPinned:
                    return "The trickle is already pinned."
                case .alreadyUnpinned:
                    return "The trickle is already unpinned."
            }
        }
    }
}

extension TrickleStore {
    internal func _lsitPinTrickles(workspaceID: WorkspaceData.ID, groupID: GroupData.ID) async {
        do {
            guard let workspace = findGroupWorkspace(groupID) else { throw TrickleStoreError.workspaceNotFound(workspaceID) }
            let data: AnyStreamable<TrickleData> = try await webRepositoryClient.listPinTrickles(workspaceID: workspaceID, groupID: groupID, query: .init(memberID: workspace.userMemberInfo.memberID))
            trickles.merge(data.items.formDic(\.trickleID)) { (_, new) in
                new
            }
            groupsPinTrickleIDs[groupID] = data.items.map{$0.trickleID}
        } catch {
            self.error = .init(error)
            groupsPinTrickleIDs[groupID]?.removeAll()
        }
    }
    public func listPinTrickles(workspaceID: WorkspaceData.ID, groupID: GroupData.ID) async {
        await _lsitPinTrickles(workspaceID: workspaceID, groupID: groupID)
    }
    public func listPinTrickles() async {
        guard let workspaceID = currentWorkspaceID,
              let groupID = currentGroupID else { return }
        await _lsitPinTrickles(workspaceID: workspaceID, groupID: groupID)
    }
    
    public func tryPinTrickle(trickleID: TrickleData.ID) async throws -> String {
        guard let group = findTrickleGroup(trickleID),
              let workspace = findGroupWorkspace(group.groupID)
        else { throw TrickleStoreError.trickleNotFound(trickleID) }
        do {
            trickles[trickleID]?.isPinned = true
            groupsPinTrickleIDs[group.groupID]?.insert(trickleID, at: 0)
            let data = try await webRepositoryClient.pinTrickle(workspaceID: workspace.workspaceID, groupID: group.groupID, trickleID: trickleID,
                                                                payload: .init(memberID: workspace.userMemberInfo.memberID))
            return data
        } catch {
            trickles[trickleID]?.isPinned = false
            groupsPinTrickleIDs[group.groupID]?.removeAll(where: {$0 == trickleID})
            throw error
        }
    }
    
    public func pinTrickle(trickleID: TrickleData.ID) async {
        do {
            _ = try await tryPinTrickle(trickleID: trickleID)
        } catch {
            self.error = .init(error)
        }
    }
    
    public func tryUnpinTrickle(trickleID: TrickleData.ID) async throws -> String {
        guard let group = findTrickleGroup(trickleID),
              let workspace = findGroupWorkspace(group.groupID)
        else { throw TrickleStoreError.trickleNotFound(trickleID) }
        guard let index = groupsPinTrickleIDs[group.groupID]?.firstIndex(of: trickleID) else { throw TrickleStoreError.pinError(.alreadyUnpinned) }
        do {
            trickles[trickleID]?.isPinned = false
            groupsPinTrickleIDs[group.groupID]?.remove(at: index)
            let data = try await webRepositoryClient.unpinTrickle(workspaceID: workspace.workspaceID, groupID: group.groupID, trickleID: trickleID)
            return data
        } catch {
            trickles[trickleID]?.isPinned = true
            groupsPinTrickleIDs[group.groupID]?.insert(trickleID, at: index)
            throw error
        }
    }
    
    public func unpinTrickle(trickleID: TrickleData.ID) async {
        do {
            _ = try await tryUnpinTrickle(trickleID: trickleID)
        } catch {
            self.error = .init(error)
        }
    }
}
