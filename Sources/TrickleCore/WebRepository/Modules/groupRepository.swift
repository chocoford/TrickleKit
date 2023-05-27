//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/15.
//

import Combine

extension TrickleWebRepository {
    func listWorkspaceGroups(workspaceID: String, memberID: String) -> AnyPublisher<WorkspaceGroupsData, Error> {
        call(endpoint: API.listWorkspaceGroups(workspaceID: workspaceID, memberID: memberID))
    }
    func listWorkspaceGroups(workspaceID: String, memberID: String) async throws -> WorkspaceGroupsData {
        try await call(endpoint: API.listWorkspaceGroups(workspaceID: workspaceID, memberID: memberID))
    }
    
//     func createChannel(workspaceID: String,
//                        memberID: String,
//                        invitedMemberIDs: [String]) -> AnyPublisher<GroupData, Error> {
//         call(endpoint: API.createChannel(workspaceID: workspaceID,
//                                          memberID: memberID,
//                                          invitedMemberIDs: invitedMemberIDs))
//     }
    
    func createGroup(workspaceID: WorkspaceData.ID, payload: API.CreateGroupPayload) async throws -> GroupData {
        try await call(endpoint: API.createGroup(workspaceID: workspaceID, payload: payload))
    }
    
    func createPersonalGroup(workspaceID: WorkspaceData.ID, memberID: MemberData.ID, payload: API.CreateGroupPayload) async throws -> GroupData {
        try await call(endpoint: API.createPersonalGroup(workspaceID: workspaceID, memberID: memberID, payload: payload))
    }
    
    func updateGroup(workspaceID: WorkspaceData.ID, groupID: GroupData.ID, payload: API.UpdateGroupPayload) async throws -> GroupData {
        try await call(endpoint: API.updateGroup(workspaceID: workspaceID, groupID: groupID, payload: payload))
    }
    
    func deleteGroup(workspaceID: WorkspaceData.ID, groupID: GroupData.ID) async throws -> String {
        try await call(endpoint: API.deleteGroup(workspaceID: workspaceID, groupID: groupID))
    }
    
    func ackGroup(workspaceID: WorkspaceData.ID, groupID: GroupData.ID, payload: API.AckGroupPayload) async throws -> String {
        try await call(endpoint: API.ackGroup(workspaceID: workspaceID, groupID: groupID, payload: payload))
    }
    
    // MARK: Fields
    func listFieldOptions(workspaceID: String, groupID: String) -> AnyPublisher<FieldsOptions, Error> {
        call(endpoint: API.listFieldOptions(workspaceID: workspaceID, groupID: groupID))
    }
    func listFieldOptions(workspaceID: String, groupID: String) async throws -> FieldsOptions {
        try await call(endpoint: API.listFieldOptions(workspaceID: workspaceID, groupID: groupID))
    }
    
    
    
}
