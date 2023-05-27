//
//  UserInfo.swift
//  TrickleKit
//
//  Created by Chocoford on 2022/11/29.
//

import Foundation

public struct AuthData: Codable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresIn: Int
    public let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}


public struct TokenInfo: Codable {
    public let sub: String
    public let iat: Int
    public let exp: Int
    public let scope: String
    
    public let token: String
    
    public init(sub: String, iat: Int, exp: Int, scope: String, token: String) {
        self.sub = sub
        self.iat = iat
        self.exp = exp
        self.scope = scope
        self.token = token
    }
}

public struct UserInfo: Codable, Equatable {
    public struct UserData: Codable, Equatable, Identifiable {
        public let id: String
        public var name: String
        public let email: String?
        public var avatarURL: String
        
        public init(id: String, name: String, email: String?, avatarURL: String) {
            self.id = id
            self.name = name
            self.email = email
            self.avatarURL = avatarURL
        }
        
        enum CodingKeys: String, CodingKey {
            case id, email
            case avatarURL = "avatarUrl"
            case name = "nickname"
        }
    }
    
    public var user: UserData
    
    public var token: String?
    
    public init(user: UserData, token: String?) {
        self.user = user
        self.token = token
    }
    
    struct KeychainRepresentation: Codable {
        let id: UUID
        let token: String
    }
}
