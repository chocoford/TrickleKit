//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/15.
//

import Foundation

extension TrickleWebRepository {
    func listGroupViewTricklesStat(workspaceID: String, groupID: String, query: API.ListGroupViewTricklesStatQuery) async throws -> GroupViewTricklesStat {
        try await call(endpoint: API.listGroupViewTricklesStat(workspaceID: workspaceID, groupID: groupID, query: query))
    }
}
