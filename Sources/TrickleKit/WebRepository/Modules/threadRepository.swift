//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/15.
//

import Combine

extension TrickleWebRepository {
    func listWorkspaceThreads(workspaceID: String, memberID: String, query: API.ListQuery) -> AnyPublisher<AnyStreamable<TrickleData>, Error> {
        call(endpoint: API.listWorkspaceThreads(workspaceID: workspaceID, memberID: memberID, query: query))
    }
    func listWorkspaceThreads(workspaceID: String, memberID: String, query: API.ListQuery) async throws -> AnyStreamable<TrickleData> {
        try await call(endpoint: API.listWorkspaceThreads(workspaceID: workspaceID, memberID: memberID, query: query))
    }
}
