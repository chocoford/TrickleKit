//
//  MemberData.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/1/29.
//

import Foundation
public struct MemberData: Codable, Hashable {
    public let memberID: String
    public let name: String
    public let role: Role
    public let status: Status
    public let avatarURL: URL?
    
    public let memberSpace: MemberSpace?
    public let email: String?
    public let lastNtfReadAt: Int?
    public let receiverID: Double?
    
    public let updateAt, createAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case name, role, email, status
        case avatarURL = "avatarUrl"
        case lastNtfReadAt
        case memberID = "memberId"
        case memberSpace
        case receiverID = "receiverId"
        case createAt, updateAt
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.role = try container.decode(MemberData.Role.self, forKey: .role)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.status = try container.decode(MemberData.Status.self, forKey: .status)
        self.avatarURL = URL(string: try container.decodeIfPresent(String.self, forKey: .avatarURL) ?? "")
        self.lastNtfReadAt = try container.decodeIfPresent(Int.self, forKey: .lastNtfReadAt)
        self.memberID = try container.decode(String.self, forKey: .memberID)
        self.memberSpace = try container.decodeIfPresent(MemberData.MemberSpace.self, forKey: .memberSpace)
        self.receiverID = try container.decodeIfPresent(Double.self, forKey: .receiverID)
        self.createAt = try container.decodeIfPresent(Date.self, forKey: .createAt)
        self.updateAt = try container.decodeIfPresent(Date.self, forKey: .updateAt)
    }
    
    public enum Role: String, Codable {
        case poster = "Poster"
        case anonymous = "Anonymous"
        case guest = "Guest"
        case admin = "Admin"
        case aasistant = "Assistant"
    }
    public enum Status: String, Codable {
        case normal = "Normal"
        case removed = "Removed"
    }
    
    public struct MemberSpace: Codable, Hashable {
        public let bio, bgURL: String?
        public let position: Int?
        public let stickers: [Sticker]?
        public let highlight: String?
        
        enum CodingKeys: String, CodingKey {
            case bio
            case bgURL = "bgUrl"
            case position, stickers, highlight
        }
    }
}

extension MemberData: Identifiable {
    public var id: String { memberID }
}

extension MemberData.MemberSpace {
    // MARK: - Sticker
    public struct Sticker: Codable, Hashable {
        public let url: String
        public let desc: String
    }
}
