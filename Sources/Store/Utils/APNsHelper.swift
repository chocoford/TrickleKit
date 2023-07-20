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
    public var baseURL: String = "https://\(Config.apiDomain)/chocoford/apns"
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
        try await call(endpoint: API.registerAPNs(payload: payload))
    }
    
    public func logoutAPNs(deviceToken: String, payload: LogoutAPNsPayload) async throws -> String {
        try await call(endpoint: API.logoutAPNs(deviceToken: deviceToken, payload: payload))
    }
    
    public func updateAPNsSettings(deviceToken: String, payload: UpdateAPNsPayload) async throws -> String {
        try await call(endpoint: API.updateAPNs(deviceToken: deviceToken, payload: payload))
    }
    
    public func mute(deviceToken: String,
                     workspaceID: WorkspaceData.ID) async throws -> String {
        try await call(endpoint: API.muteWorkspace(payload: .init(deviceToken: deviceToken,
                                                                  workspaceID: workspaceID)))
    }
    
    public func unmute(deviceToken: String,
                workspaceID: WorkspaceData.ID,
                memberID: MemberData.ID,
                token: String) async throws -> String {
        try await call(endpoint: API.unmuteWorkspace(payload: .init(deviceToken: deviceToken,
                                                                    workspaceInfo: .init(workspaceID: workspaceID,
                                                                                         memberID: memberID),
                                                                    token: token)))
    }
}

public extension TrickleAPNsHelper {
    enum Env: String, Codable {
        case dev
        case test
        case live
    }
    struct WorkspaceEnableState: Codable {
        var newPost: Bool
        var newComment: Bool
        var mentions: Bool
        var reaction: Bool
        var directMessages: Bool
        
        public init(newPost: Bool, newComment: Bool, mentions: Bool, reaction: Bool, directMessages: Bool) {
            self.newPost = newPost
            self.newComment = newComment
            self.mentions = mentions
            self.reaction = reaction
            self.directMessages = directMessages
        }
        
        public static var `default`: WorkspaceEnableState = WorkspaceEnableState(newPost: true, newComment: true, mentions: true, reaction: true, directMessages: true)
    }
    struct RegisterAPNsPayload: Codable {
        public typealias WorkspaceEnableStates = [WorkspaceData.ID : WorkspaceInfo]
        
        let deviceToken: String
        let userID: UserInfo.UserData.ID
        let env: Env
        let workspaceEnableStates: WorkspaceEnableStates
        let isSandbox: Bool

        public init(deviceToken: String, userID: String, env: Env, workspaceEnableStates: WorkspaceEnableStates, isSandbox: Bool) {
            self.deviceToken = deviceToken
            self.userID = userID
            self.env = env
            self.workspaceEnableStates = workspaceEnableStates
            self.isSandbox = isSandbox
        }


        
        public struct WorkspaceInfo: Codable {
            public var memberID: MemberData.ID
            public var enableStates: WorkspaceEnableState
            
            public init(memberID: MemberData.ID, enableStates: WorkspaceEnableState) {
                self.memberID = memberID
                self.enableStates = enableStates
            }
            
           
        }
    }
    
    struct UpdateAPNsPayload: Codable {
//        let deviceToken: String
        let workspaceID: WorkspaceData.ID
        let env: Env
        let enableStates: WorkspaceEnableState
        let isSandbox: Bool
        
        enum CodingKeys: String, CodingKey {
            case workspaceID = "workspaceId"
            case env
            case enableStates
            case isSandbox
        }
    }
    
    struct LogoutAPNsPayload: Codable {
        let isSandbox: Bool
    }
}


extension TrickleAPNsHelper {
    enum API {
        case registerAPNs(payload: TrickleAPNsHelper.RegisterAPNsPayload)
        case updateAPNs(deviceToken: String, payload: TrickleAPNsHelper.UpdateAPNsPayload)
        case logoutAPNs(deviceToken: String, payload: TrickleAPNsHelper.LogoutAPNsPayload)
        case muteWorkspace(payload: MuteWorkspacePayload)
        case unmuteWorkspace(payload: UnmuteWorkspacePayload)
    }
}

extension TrickleAPNsHelper.API {
//    struct RegisterAPNsPayload: Codable {
//        let deviceToken, trickleToken, userID: String
//        let env: Env
//        let userWorkspaces: [WorkspaceData.ID : [PNType : Bool]]
//
//        public struct UserWorkspace: Codable {
//            let memberID, workspaceID: String
//        }
//
//        public enum Env: String, Codable {
//            case dev
//            case test
//            case live
//        }
//
//        public enum PNType: String, Codable {
//            case newTrickle
//            case comment
//            case mention
//            case reaction
//        }
//    }
    
    struct MuteWorkspacePayload: Codable {
        let deviceToken: String
        let workspaceID: WorkspaceData.ID
    }
    struct UnmuteWorkspacePayload: Codable {
        let deviceToken: String
        let workspaceInfo: APNsWorkspaceInfo
        let token: String
    }
    
    struct APNsWorkspaceInfo: Codable {
        let workspaceID: WorkspaceData.ID
        let memberID: MemberData.ID
    }
}

extension TrickleAPNsHelper.API: APICall {
    var path: String {
        switch self {
            case .registerAPNs:
                return "/users/register"
                
            case .updateAPNs(let deviceToken, _):
                return "/users/update_enable_states/\(deviceToken)"
                
            case .logoutAPNs(let deviceToken, _):
                return "/users/logout/\(deviceToken)"
                
            case .muteWorkspace:
                return "/users/mute"
            case .unmuteWorkspace:
                return "/users/unmute"
        }
    }
    
    var method: APIMethod {
        switch self {
            case .registerAPNs,
                    .updateAPNs,
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
            case .updateAPNs(_, let payload):
                return try makeBody(payload: payload)
            case .logoutAPNs(_, let payload):
                return try makeBody(payload: payload)
            case .muteWorkspace(let payload):
                return try makeBody(payload: payload)
            case .unmuteWorkspace(let payload):
                return try makeBody(payload: payload)
//            default:
//                return nil
        }
    }
}
