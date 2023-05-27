//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/15.
//

import Combine

extension TrickleWebRepository {
    func pinTrickle(workspaceID: WorkspaceData.ID, groupID: GroupData.ID, trickleID: TrickleData.ID, payload: TrickleWebRepository.API.PinTricklePayload) async throws -> String {
        try await call(endpoint: API.pinTrickle(workspaceID: workspaceID, groupID: groupID, trickleID: trickleID, payload: payload))
    }
    
    func unpinTrickle(workspaceID: WorkspaceData.ID, groupID: GroupData.ID, trickleID: TrickleData.ID) async throws -> String {
        try await call(endpoint: API.unpinTrickle(workspaceID: workspaceID, groupID: groupID, trickleID: trickleID))
    }
    
    func listPinTrickles(workspaceID: WorkspaceData.ID, groupID: GroupData.ID, query: TrickleWebRepository.API.ListPinTrickleQuery) async throws -> AnyStreamable<TrickleData> {
        try await call(endpoint: API.listPinTrickles(workspaceID: workspaceID, groupID: groupID, query: query))
    }
}
