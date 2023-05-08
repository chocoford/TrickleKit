//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/15.
//

import Foundation

extension TrickleWebRepository {
    func createTrickleReaction(workspaceID: String, trickleID: String, payload: API.CreateReactionPayload) async throws -> ReactionData {
        try await call(endpoint: API.createTrickleReaction(workspaceID: workspaceID, trickleID: trickleID, payload: payload))
    }
    func deleteTrickleReaction(workspaceID: String, trickleID: String, reactionID: String, payload: API.MemberOnlyPayload) async throws -> String {
        try await call(endpoint: API.deleteTrickleReaction(workspaceID: workspaceID, trickleID: trickleID, reactionID: reactionID, payload: payload))
    }
    
}
