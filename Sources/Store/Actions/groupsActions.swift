//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/6.
//

import Foundation
import ChocofordUIEssentials
import TrickleCore
// Web
public extension TrickleStore {
    func loadWorkspaceGroups(_ workspaceID: WorkspaceData.ID, silent: Bool = false) async {
        if !silent {
            workspacesGroups[workspaceID]?.setIsLoading()
        }
        do {
            guard let memberID = workspaces[workspaceID]?.userMemberInfo.memberID else { throw TrickleStoreError.invalidWorkspaceID(workspaceID) }

            let data = try await webRepositoryClient.listWorkspaceGroups(workspaceID: workspaceID, memberID: memberID)
            workspacesGroups[workspaceID] = .loaded(data: data)
        } catch {
            self.error = .init(error)
            workspacesGroups[workspaceID]?.setAsFailed(error)
        }
    }

    func loadGroupFieldsOptions(_ groupID: GroupData.ID) async {
        do {
            let workspace = try findGroupWorkspace(groupID)
            groupsFieldsOptions[groupID]?.setIsLoading()
            let data = try await webRepositoryClient.listFieldOptions(workspaceID: workspace.workspaceID, groupID: groupID)
            groupsFieldsOptions[groupID] = .loaded(data: data)
        } catch {
            self.error = .init(error)
            groupsFieldsOptions[groupID]?.setAsFailed(error)
        }
    }
    
    func tryCreateGroup(workspaceID: WorkspaceData.ID?,
                        name: String,
                        icon: String? = nil,
                        type: GroupData.ChannelType,
                        isPublic: Bool,
                        isPersonal: Bool,
                        memberIDs: [String]) async throws -> GroupData {
        
        guard let workspaceID = workspaceID ?? currentWorkspaceID,
                let workspace = workspaces[workspaceID] else {
            throw TrickleStoreError.invalidWorkspaceID(workspaceID)
        }
        var memberIDs = memberIDs
        if !memberIDs.contains(workspace.userMemberInfo.memberID) {
            memberIDs.append(workspace.userMemberInfo.memberID)
        }
        let groupData: GroupData
        if !isPersonal {
            groupData = try await webRepositoryClient.createGroup(workspaceID: workspaceID, payload: .init(name: name,
                                                                                                               memberIDs: memberIDs,
                                                                                                               isWorkspacePublic: isPublic,
                                                                                                               ownerID: workspace.userMemberInfo.memberID,
                                                                                                               channelType: type))
            workspacesGroups[workspace.workspaceID] = workspacesGroups[workspace.workspaceID]?.map { .init(team: $0.team + [groupData],
                                                                                                           personal: $0.personal) }
        } else {
            groupData = try await webRepositoryClient.createPersonalGroup(workspaceID: workspaceID,
                                                                          memberID: workspace.userMemberInfo.memberID,
                                                                          payload: .init(name: name,
                                                                                         memberIDs: [],
                                                                                         isWorkspacePublic: isPublic,
                                                                                         ownerID: workspace.userMemberInfo.memberID,
                                                                                         channelType: type))
            
            workspacesGroups[workspace.workspaceID] = workspacesGroups[workspace.workspaceID]?.map { .init(team: $0.team,
                                                                                                           personal: $0.personal + [groupData]) }
        }
        
        return groupData
    }
    
    func createGroup(workspaceID: WorkspaceData.ID?,
                     name: String,
                     icon: String? = nil,
                     type: GroupData.ChannelType,
                     isPublic: Bool,
                     isPersonal: Bool,
                     memberIDs: [String]) async {
        do {
            let groupData = try await tryCreateGroup(workspaceID: workspaceID, name: name, icon: icon, type: type, isPublic: isPublic, isPersonal: isPersonal, memberIDs: memberIDs)
            
            currentGroupID = groupData.groupID
        } catch {
            self.error = .init(error)
        }
    }
    
    func updateGroupInfo(groupID: String?, name: String?, icon: String?, isPublic: Bool?) async {
        do {
            guard let groupID = groupID ?? currentGroupID,
                  var group = groups[groupID] else { throw TrickleStoreError.invalidGroupID(groupID) }
            let workspace = try findGroupWorkspace(groupID)
            let backupGroup = group
            if let name = name {
                group.name = name
            }
            if let icon = icon {
                group.icon = icon
            }
            if let isPublic = isPublic {
                group.isWorkspacePublic = isPublic
            }
            
            workspacesGroups[workspace.workspaceID] = workspacesGroups[workspace.workspaceID]?.map {
                .init(team:  $0.team.updatingItem(group),
                      personal:  $0.personal.updatingItem(group))
            }
            do {
                _ = try await webRepositoryClient.updateGroup(workspaceID: workspace.workspaceID,
                                                              groupID: groupID,
                                                              payload: .init(name: name,
                                                                             icon: icon,
                                                                             isPublic: isPublic,
                                                                             memberID: workspace.userMemberInfo.memberID))
            } catch {
                workspacesGroups[workspace.workspaceID] = workspacesGroups[workspace.workspaceID]?.map {
                    .init(team:  $0.team.updatingItem(backupGroup),
                          personal:  $0.personal.updatingItem(backupGroup))
                }
                throw error
            }
        } catch {
            self.error = .init(error)
        }
    }
    
    func deleteGroup(groupID: String?) async {
        do {
            guard let groupID = groupID ?? currentGroupID,
                  let group = groups[groupID] else { throw TrickleStoreError.invalidGroupID(groupID) }
            let workspace = try findGroupWorkspace(groupID)
            _ = try await webRepositoryClient.deleteGroup(workspaceID: workspace.workspaceID, groupID: groupID)
            
            workspacesGroups[workspace.workspaceID] = workspacesGroups[workspace.workspaceID]?.map { .init(team: $0.team.removingItem(group),
                                                                                                           personal: $0.personal.removingItem(group)) }
            
        } catch {
            self.error = .init(error)
        }
    }

    func tryAckGroup(groupID: GroupData.ID?) async throws {
        guard let groupID = groupID ?? currentGroupID,
              var group = groups[groupID] else { throw TrickleStoreError.invalidGroupID(groupID) }
        let workspace = try findGroupWorkspace(groupID)

        let oldLastViewInfo = group.lastViewInfo
        do {
            group.lastViewInfo.unreadCount = 0
            group.lastViewInfo.lastACKTrickleCreateAt = groupsTrickles[groupID]?.max(by: {$0.createAt > $1.createAt})?.createAt ?? .now
            workspacesGroups[workspace.workspaceID] = workspacesGroups[workspace.workspaceID]?.map { .init(team: $0.team.updatingItem(group),
                                                                                                           personal: $0.personal.updatingItem(group)) }
            
            _ = try await webRepositoryClient.ackGroup(workspaceID: workspace.workspaceID, groupID: groupID, payload: .init(memberID: workspace.userMemberInfo.memberID))
        } catch {
            group.lastViewInfo.unreadCount = oldLastViewInfo.unreadCount
            group.lastViewInfo.lastACKTrickleCreateAt = oldLastViewInfo.lastACKTrickleCreateAt

            workspacesGroups[workspace.workspaceID] = workspacesGroups[workspace.workspaceID]?.map { .init(team: $0.team.updatingItem(group),
                                                                                                           personal: $0.personal.updatingItem(group)) }
            throw error
        }
    }
    
    func ackGroup(groupID: GroupData.ID?) async {
        do {
            try await tryAckGroup(groupID: groupID)
        } catch {
            self.error = .init(error)
        }
    }
}

// Non-web
extension TrickleStore {
    public func setGroupToLastChoosen() {
        guard let workspaceID = currentWorkspaceID else { return }
        currentGroupID = lastWorkspacesGroupID[workspaceID] ?? workspacesGroups[workspaceID]?.value?.team.first?.groupID
    }
}
