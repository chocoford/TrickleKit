//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/15.
//

import Combine

extension TrickleWebRepository {
    func listUserWorkspaces(userID: String) -> AnyPublisher<AnyStreamable<WorkspaceData>, Error> {
        call(endpoint: API.listWorkspaces(userID: userID))
    }
    func listUserWorkspaces(userID: String) async throws -> AnyStreamable<WorkspaceData> {
        try await call(endpoint: API.listWorkspaces(userID: userID))
    }
    
    func getWorkspaceInvitations(workspaceID: WorkspaceData.ID) async throws -> [WorkspaceInvitationData] {
        try await call(endpoint: API.getWorkspaceInvitations(workspaceID: workspaceID))
    }
    func createWorkspaceInvitation(workspaceID: WorkspaceData.ID, payload: API.CreateWorkspaceInvitationPayload) async throws -> API.CreateWorkspaceInvitationResponseData {
        try await call(endpoint: API.createWorkspaceInvitation(workspaceID: workspaceID, payload: payload))
    }
    func createWorkspace(payload: API.CreateWorkspacePayload) async throws -> API.CreateWorkspaceResponseData {
        try await call(endpoint: API.createWorkspace(payload: payload))
    }
    func updateWorkspace(workspaceID: WorkspaceData.ID, payload: API.UpdateWorkspacePayload) async throws -> TrickleWebRepository.API.UpdateWorkspaceResponseData {
        try await call(endpoint: API.updateWorkspace(workspaceID: workspaceID, payload: payload))
    }
    func leaveWorkspace(workspaceID: WorkspaceData.ID, payload: API.MemberOnlyPayload) async throws -> String {
        try await call(endpoint: API.leaveWorkspace(workspaceID: workspaceID, payload: payload))
    }
    func sendWorkspaceInvitations(workspaceID: String, invitationID: String, payload: API.SendEmailPayload) async throws -> String {
        try await call(endpoint: API.sendWorkspaceInvitations(workspaceID: workspaceID, invitationID: invitationID, payload: payload))
    }
}
