//
//  WorkspaceData.swift
//  TrickleKit
//
//  Created by Chocoford on 2022/12/21.
//

import Foundation

// MARK: - Workspace Data
public struct WorkspaceData: Codable, Hashable {
    public var workspaceID: String
    public var ownerID, name: String
    public var memberNum, removedMemberNum: Int?
    public var logo: String
    public var domain: String
    public var userID: String
    public var createAt, updateAt: Date
    public var userMemberInfo: MemberData
    public var hasUnread: Bool
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case workspaceID = "workspaceId"
        case ownerID = "ownerId"
        case name, memberNum, removedMemberNum, logo, domain
        case userID = "userId"
        case createAt, updateAt, userMemberInfo, hasUnread
    }
}

extension WorkspaceData: Identifiable {
    public var id: String {
        workspaceID
    }
}

public extension WorkspaceData {
    enum Domain: String, Codable {
        case empty = ""
        case testWorkspaceTrickleSo = "test.workspace.trickle.so"
    }
    mutating func update(by dict: [String : AnyDictionaryValue]) {
        guard !dict.isEmpty else { return }
        for key in CodingKeys.allCases {
            guard let val = dict[key.rawValue] else { continue }
            switch key {
                case .workspaceID:
                    if case .string(let workspaceID) = val {
                        self.workspaceID = workspaceID
                    }
                case .ownerID:
                    if case .string(let ownerID) = val {
                        self.ownerID = ownerID
                    }
                case .name:
                    if case .string(let name) = val {
                        self.name = name
                    }
                case .memberNum:
                    if case .int(let memberNum) = val {
                        self.memberNum = memberNum
                    }
                case .removedMemberNum:
                    if case .int(let removedMemberNum) = val {
                        self.removedMemberNum = removedMemberNum
                    }
                case .logo:
                    if case .string(let logo) = val {
                        self.logo = logo
                    }
                case .domain:
                    if case .string(let domain) = val {
                        self.domain = domain
                    }
                case .userID:
                    if case .string(let userID) = val {
                        self.userID = userID
                    }
                case .createAt:
                    if case .double(let createdAt) = val {
                        self.createAt = Date(timeIntervalSince1970: createdAt)
                    }
                case .updateAt:
                    if case .double(let updateAt) = val {
                        self.updateAt = Date(timeIntervalSince1970: updateAt)
                    }
                case .userMemberInfo:
                    if case .dictinoary(let userMemberInfo) = val,
                       let userMemberInfo = try? userMemberInfo.decode(to: MemberData.self)  {
                        self.userMemberInfo = userMemberInfo
                    }
                case .hasUnread:
                    if case .bool(let hasUnread) = val {
                        self.hasUnread = hasUnread
                    }
            }
        }
    }

//    mutating func update(by dict: [String : AnyDictionaryValue]) {
//        dict.forEach { (key, val) in
//            if case .string(let workspaceID) = dict[key] {
//                self.workspaceID = workspaceID
//            }
//            if case .string(let ownerID) = dict[key] {
//                self.ownerID = ownerID
//            }
//            if case .string(let name) = dict[key] {
//                self.name = name
//            }
//            if case .int(let memberNum) = dict[key] {
//                self.memberNum = memberNum
//            }
//            if case .int(let removedMemberNum) = dict[key] {
//                self.removedMemberNum = removedMemberNum
//            }
//            if case .string(let logo) = dict[key] {
//                self.logo = logo
//            }
//            if case .string(let domain) = dict[key] {
//                self.domain = domain
//            }
//            if case .string(let userID) = dict[key] {
//                self.userID = userID
//            }
//            if case .double(let createAt) = dict[key] {
//                self.createAt = Date(timeIntervalSince1970: createAt)
//            }
//            if case .double(let updateAt) = dict[key] {
//                self.updateAt = Date(timeIntervalSince1970: updateAt)
//            }
//            if case .dictinoary(let userMemberInfo) = dict[key],
//               let userMemberInfo = try? userMemberInfo.decode(to: MemberData.self) {
//                self.userMemberInfo = userMemberInfo
//            }
//            if case .bool(let hasUnread) = dict[key] {
//                self.hasUnread = hasUnread
//            }
//        }
//    }

}


public struct WorkspaceInvitationData: Codable, Hashable {
    public let workspaceInvitationID: String
    public let role: MemberData.Role?
    public let expireAt: Int
    public let allowedEmailDomains, allowedEmails: [String]
    public let needConfirm: Bool
    public let enable: Bool

    enum CodingKeys: String, CodingKey {
        case workspaceInvitationID = "workspaceInvitationId"
        case role, expireAt, allowedEmailDomains, needConfirm, allowedEmails, enable
    }
}



