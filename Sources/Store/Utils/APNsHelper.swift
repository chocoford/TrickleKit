//
//  TrickleAPNsHelper.swift
//  
//
//  Created by Dove Zachary on 2023/5/26.
//

import Foundation
import Logging
import CFWebRepositoryProvider
import TrickleCore

public struct TrickleAPNsHelper: WebRepositoryProvider {
    public var logLevel: [LogOption]
    public var logger: Logger = .init(label: "TrickleAPNsHelper")
    public var session: URLSession = .shared
    public var baseURL: String = "http://64.176.193.239" //"http://192.168.2.9"
    public var bgQueue: DispatchQueue = DispatchQueue(label: "bg_trickle_queue")
    public var responseDataDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()
    
    public init(_ logLevel: [LogOption] = [.response, .data]) {
        self.logLevel = logLevel
    }
    
    public func registerAPNs(payload: RegisterAPNsPayload) async throws -> String {
        try await call(endpoint: API.registerAPNs(payload: .init(deviceToken: payload.deviceToken,
                                                                 trickleToken: payload.trickleToken,
                                                                 userID: payload.userID,
                                                                 env: .init(rawValue: payload.env.rawValue)!,
                                                                 userWorkspaces: payload.userWorkspaces.map{.init(memberID: $0.memberID,
                                                                                                                  workspaceID: $0.workspaceID)})))
    }
    
    public func logoutAPNs(userID: UserInfo.UserData.ID) async throws -> String {
        try await call(endpoint: API.logoutAPNs(userID: userID))
    }
    
    public func mute(userID: UserInfo.UserData.ID,
              workspaceID: WorkspaceData.ID,
              memberID: MemberData.ID) async throws -> String {
        try await call(endpoint: API.muteWorkspace(payload: .init(userID: userID,
                                                                  workspaceID: workspaceID,
                                                                  memberID: memberID)))
    }
    
    public func unmute(userID: UserInfo.UserData.ID,
                workspaceID: WorkspaceData.ID,
                memberID: MemberData.ID,
                token: String) async throws -> String {
        try await call(endpoint: API.unmuteWorkspace(payload: .init(userID: userID,
                                                                  workspaceID: workspaceID,
                                                                  memberID: memberID, token: token)))
    }
}

public extension TrickleAPNsHelper {
    struct RegisterAPNsPayload: Codable {
        let deviceToken, trickleToken, userID: String
        let env: Env
        let userWorkspaces: [UserWorkspace]

        public init(deviceToken: String, trickleToken: String, userID: String, env: Env, userWorkspaces: [UserWorkspace]) {
            self.deviceToken = deviceToken
            self.trickleToken = trickleToken
            self.userID = userID
            self.env = env
            self.userWorkspaces = userWorkspaces
        }
        
        public struct UserWorkspace: Codable {
            let memberID, workspaceID: String
            
            public init(memberID: String, workspaceID: String) {
                self.memberID = memberID
                self.workspaceID = workspaceID
            }
        }

        public enum Env: String, Codable {
            case dev
            case test
            case live
        }
    }
}


extension TrickleAPNsHelper {
    enum API {
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
