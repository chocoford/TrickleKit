//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/15.
//

import Combine
import TrickleCore

extension TrickleWebRepository {
    func listWorkspaceThreads(workspaceID: String, memberID: String, query: API.ListQuery) -> AnyPublisher<AnyStreamable<TrickleData>, Error> {
        call(endpoint: API.listWorkspaceThreads(workspaceID: workspaceID, memberID: memberID, query: query))
    }
    func listWorkspaceThreads(workspaceID: String, memberID: String, query: API.ListQuery) async throws -> AnyStreamable<TrickleData> {
        try await call(endpoint: API.listWorkspaceThreads(workspaceID: workspaceID, memberID: memberID, query: query))
    }
    
    func getWorkspaceThreadsUnreadCount(workspaceID: String, memberID: String) async throws -> API.ThreadsUnreadCountResponse {
        try await call(endpoint: API.getWorkspaceThreadsUnreadCount(workspaceID: workspaceID, memberID: memberID))
    }
}
