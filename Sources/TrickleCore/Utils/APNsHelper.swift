//
//  TrickleAPNsHelper.swift
//  
//
//  Created by Dove Zachary on 2023/5/26.
//

import Foundation
import OSLog
import CFWebRepositoryProvider

struct TrickleAPNsHelper: WebRepositoryProvider {
    var logLevel: [LogOption]
    var logger: Logger = .init(subsystem: "TrickleKit", category: "TrickleAPNsHelper")
    var session: URLSession = .shared
    var baseURL: String = "http://64.176.193.239" //"http://192.168.2.9"
    var bgQueue: DispatchQueue = DispatchQueue(label: "bg_trickle_queue")
    var responseDataDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()
    
    init(_ logLevel: [LogOption] = [.response, .data]) {
        self.logLevel = logLevel
    }
    
    func registerAPNs(payload: API.RegisterAPNsPayload) async throws -> String {
        try await call(endpoint: API.registerAPNs(payload: payload))
    }
    
    func logoutAPNs(userID: UserInfo.UserData.ID) async throws -> String {
        try await call(endpoint: API.logoutAPNs(userID: userID))
    }
    
    func mute(userID: UserInfo.UserData.ID,
              workspaceID: WorkspaceData.ID,
              memberID: MemberData.ID) async throws -> String {
        try await call(endpoint: API.muteWorkspace(payload: .init(userID: userID,
                                                                  workspaceID: workspaceID,
                                                                  memberID: memberID)))
    }
    
    func unmute(userID: UserInfo.UserData.ID,
                workspaceID: WorkspaceData.ID,
                memberID: MemberData.ID,
                token: String) async throws -> String {
        try await call(endpoint: API.unmuteWorkspace(payload: .init(userID: userID,
                                                                  workspaceID: workspaceID,
                                                                  memberID: memberID, token: token)))
    }
}


extension TrickleAPNsHelper {
    public enum API {
        case registerAPNs(payload: RegisterAPNsPayload)
        case logoutAPNs(userID: UserInfo.UserData.ID)
        case muteWorkspace(payload: MuteWorkspacePayload)
        case unmuteWorkspace(payload: UnmuteWorkspacePayload)
    }
}


extension TrickleAPNsHelper.API {
    struct RegisterAPNsPayload: Codable {
        let deviceToken, trickleToken, userID: String
        let env: Env
        let userWorkspaces: [UserWorkspace]

        public struct UserWorkspace: Codable {
            let memberID, workspaceID: String
        }

        public enum Env: String, Codable {
            case dev
            case test
            case live
        }
    }
    
    struct MuteWorkspacePayload: Codable {
        let userID: UserInfo.UserData.ID
        let workspaceID: WorkspaceData.ID
        let memberID: MemberData.ID
    }
    struct UnmuteWorkspacePayload: Codable {
        let userID: UserInfo.UserData.ID
        let workspaceID: WorkspaceData.ID
        let memberID: MemberData.ID
        let token: String
    }
}

extension TrickleAPNsHelper.API: APICall {
    var path: String {
        switch self {
            case .registerAPNs:
                return "/users/register"
                
            case .logoutAPNs(let userID):
                return "/users/logout/\(userID)"
                
            case .muteWorkspace:
                return "/users/mute"
            case .unmuteWorkspace:
                return "/users/unmute"
        }
    }
    
    var method: APIMethod {
        switch self {
            case .registerAPNs,
                    .logoutAPNs,
                    .muteWorkspace,
                    .unmuteWorkspace:
                return .post
        }
    }
    
    var headers: [String : String]? {
        switch self.method {
            case .post:
                return ["Content-Type": "application/json"]
            default:
                return nil
        }
    }
    
    var gloabalQueryItems: Codable? {
        nil
    }
    
    var queryItems: Codable? {
        switch self {
            default:
                return nil
        }
    }
    
    func body() throws -> Data? {
        switch self {
            case .registerAPNs(let payload):
                return try makeBody(payload: payload)
            case .muteWorkspace(let payload):
                return try makeBody(payload: payload)
            case .unmuteWorkspace(let payload):
                return try makeBody(payload: payload)
            default:
                return nil
        }
    }
}
