//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/15.
//

import Combine

extension TrickleWebRepository {
    func createTrickleComments(workspaceID: String, trickleID: String, payload: API.CreateCommentPayload) async throws -> TrickleWebRepository.API.CreateCommentResponseData {
        try await call(endpoint: API.createTrickleComment(workspaceID: workspaceID, trickleID: trickleID, payload: payload))
    }
//    func listTrickleComments(workspaceID: String, trickleID: String, query: API.ListQuery) -> AnyPublisher<AnyStreamable<CommentData>, Error> {
//        call(endpoint: API.listTrickleComments(workspaceID: workspaceID, trickleID: trickleID, query: query))
//    }
    func listTrickleComments(workspaceID: String, trickleID: String, query: API.ListQuery) async throws -> AnyStreamable<CommentData> {
        try await call(endpoint: API.listTrickleComments(workspaceID: workspaceID, trickleID: trickleID, query: query))
    }
    
    func ackTrickleComments(workspaceID: WorkspaceData.ID, trickleID: TrickleData.ID, payload: API.ACKTrickleCommentsPayload) async throws -> String {
        try await call(endpoint: API.ackTrickleComments(workspaceID: workspaceID, trickleID: trickleID, payload: payload))
    }
}
