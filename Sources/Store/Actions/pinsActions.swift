//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/6.
//

import Foundation
import TrickleCore

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
            let workspace = try findGroupWorkspace(groupID)
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
    public func listPinTrickles(workspaceID: WorkspaceData.ID? = nil, groupID: GroupData.ID) async {
        do {
            if let workspaceID = workspaceID {
                await _lsitPinTrickles(workspaceID: workspaceID, groupID: groupID)
            } else {
                let workspaceID = try findGroupWorkspace(groupID).workspaceID
                await _lsitPinTrickles(workspaceID: workspaceID, groupID: groupID)
            }
        } catch {
            self.error = .init(error)
        }
    }
    
    @available(*, deprecated)
    public func listPinTrickles() async {
        guard let workspaceID = currentWorkspaceID,
              let groupID = currentGroupID else { return }
        await _lsitPinTrickles(workspaceID: workspaceID, groupID: groupID)
    }
    
    public func tryPinTrickle(trickleID: TrickleData.ID) async throws -> String {
        let group = try findTrickleGroup(trickleID)
        let workspace = try findGroupWorkspace(group.groupID)
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
        let group = try findTrickleGroup(trickleID)
        let workspace = try findGroupWorkspace(group.groupID)
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


extension TrickleStore {
    func addPinTrickle(_ pin: TrickleData, to groupID: GroupData.ID, afterID: TrickleData.ID? = nil) {
        if groupsPinTrickleIDs[groupID] == nil {
            groupsPinTrickleIDs[groupID] = []
        }
        groupsPinTrickleIDs[groupID]?.removeAll(where: {$0 == pin.trickleID})
        
        trickles[pin.trickleID] = pin
        
        if let afterID = afterID,
           let index = groupsPinTrickleIDs[groupID]?.firstIndex(of: afterID) {
            groupsPinTrickleIDs[groupID]?.insert(pin.trickleID, at: index)
        } else {
            groupsPinTrickleIDs[groupID]?.append(pin.trickleID)
        }
    }
}
