//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/6/28.
//

import Foundation
import TrickleCore

extension TrickleWebRepository {
    func createWorkspaceDirectMessage(workspaceID: WorkspaceData.ID, memberID: MemberData.ID, payload: API.CreateDirectMessagePayload) async throws -> TrickleData {
        try await call(endpoint: API.createWorkspaceDirectMessage(workspaceID: workspaceID, memberID: memberID, payload: payload))
    }
    func listWorkspaceDirectMessages(workspaceID: WorkspaceData.ID, memberID: MemberData.ID, query: API.ListQuery) async throws -> AnyStreamable<TrickleData> {
        try await call(endpoint: API.listWorkspaceDirectMessages(workspaceID: workspaceID, memberID: memberID, query: query))
    }
    func getWorkspaceDirectMessagesUnreadCount(workspaceID: WorkspaceData.ID, memberID: MemberData.ID) async throws -> API.DirectMessagesUnreadCountResponse {
        try await call(endpoint: API.getWorkspaceDirectMessagesUnreadCount(workspaceID: workspaceID, memberID: memberID))
    }
}
