//
//  File.swift
//  
//
//  Created by Chocoford on 2023/5/2.
//

import Foundation
import TrickleCore

extension TrickleWebRepository {
    func starTrickle(workspaceID: WorkspaceData.ID, trickleID: TrickleData.ID, payload: API.StarTricklePayload) async throws -> String {
        try await call(endpoint: API.starTrickle(workspaceID: workspaceID, trickleID: trickleID, payload: payload))
    }
    
    func unstarTrickle(workspaceID: WorkspaceData.ID, trickleID: TrickleData.ID, payload: API.UnstarTricklePayload) async throws -> String {
        try await call(endpoint: API.unstarTrickle(workspaceID: workspaceID, trickleID: trickleID, payload: payload))
    }
}
