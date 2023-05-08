//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/15.
//

import Combine
extension TrickleWebRepository {
    
    func createPost(workspaceID: String,
                      channelID: String,
                      payload: TrickleWebRepository.API.CreatePostPayload) -> AnyPublisher<TrickleData, Error> {
         call(endpoint: API.createPost(workspaceID: workspaceID, channelID: channelID, payload: payload))
     }
    func createPost(workspaceID: String,
                     channelID: String,
                     payload: TrickleWebRepository.API.CreatePostPayload) async throws -> TrickleData {
        try await call(endpoint: API.createPost(workspaceID: workspaceID, channelID: channelID, payload: payload))
    }
    
    func listTrickles(workspaceID: String,
                     query: TrickleWebRepository.API.ListTricklesQuery) -> AnyPublisher<AnyStreamable<TrickleData>, Error> {
        call(endpoint: API.listTrickles(workspaceID: workspaceID, query: query))
    }
    func listTrickles(workspaceID: String,
                     query: TrickleWebRepository.API.ListTricklesQuery) async throws -> AnyStreamable<TrickleData> {
        try await call(endpoint: API.listTrickles(workspaceID: workspaceID, query: query))
    }
    
    func listGroupTrickles(workspaceID: String,
                              groupID: String,
                              query:  NextQuery) -> AnyPublisher<AnyQueryStreamable<TrickleData>, Error> {
           call(endpoint: API.listGroupTrickles(workspaceID: workspaceID, groupID: groupID, payload: query))
       }
    func listGroupTrickles(workspaceID: String,
                           groupID: String,
                           query: NextQuery) async throws -> AnyQueryStreamable<TrickleData> {
        try await call(endpoint: API.listGroupTrickles(workspaceID: workspaceID, groupID: groupID, payload: query))
    }
    
    func copyTrickle(workspaceID: WorkspaceData.ID, trickleID: TrickleData.ID, payload: API.CopyTricklePayload) async throws -> API.CopyTrickleResponse {
        try await call(endpoint: API.copyTrickle(workspaceID: workspaceID, trickleID: trickleID, payload: payload))
    }
}
