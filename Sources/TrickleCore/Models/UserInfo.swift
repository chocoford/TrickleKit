//
//  UserInfo.swift
//  TrickleKit
//
//  Created by Chocoford on 2022/11/29.
//

import Foundation

struct AuthData: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}


public struct TokenInfo: Codable {
    let sub: String
    let iat: Int
    let exp: Int
    let scope: String
    
    let token: String
}

public struct UserInfo: Codable, Equatable {
    public struct UserData: Codable, Equatable, Identifiable {
        public let id: String
        public var name: String
        public let email: String?
        public var avatarURL: String
        
        enum CodingKeys: String, CodingKey {
            case id, email
            case avatarURL = "avatarUrl"
            case name = "nickname"
        }
    }
    
    public var user: UserData
    
    var token: String?
    
    
    
    
    struct KeychainRepresentation: Codable {
        let id: UUID
        let token: String
    }
}
