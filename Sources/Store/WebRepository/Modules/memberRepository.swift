//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/15.
//

import Combine
import TrickleCore

extension TrickleWebRepository {
    func listWorkspaceMembers(workspaceID: String, limit: Int = 9999) -> AnyPublisher<AnyStreamable<MemberData>, Error> {
        call(endpoint: API.listWorkspaceMembers(workspaceID: workspaceID, limit: limit))
    }
    func listWorkspaceMembers(workspaceID: String, limit: Int = 9999) async throws -> AnyStreamable<MemberData> {
        try await call(endpoint: API.listWorkspaceMembers(workspaceID: workspaceID, limit: limit))
    }
    
    func listGroupMembers(workspaceID: String, groupID: String) -> AnyPublisher<AnyStreamable<MemberData>, Error> {
        call(endpoint: API.listGroupMembers(workspaceID: workspaceID, groupID: groupID))
    }
    func listGroupMembers(workspaceID: String, groupID: String) async throws -> AnyStreamable<MemberData> {
        try await call(endpoint: API.listGroupMembers(workspaceID: workspaceID, groupID: groupID))
    }
}
