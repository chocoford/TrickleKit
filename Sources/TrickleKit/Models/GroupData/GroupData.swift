//
//  GroupData.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/1/29.
//

import Foundation

public struct WorkspaceGroupsData: Codable, Hashable {
    public let team: [GroupData]
    public let personal: [GroupData]
}

// MARK: - GroupData
public struct GroupData: Codable, Hashable {
    public var groupID, ownerID, name: String
    public var isWorkspacePublic: Bool
    public var channelSpace: ChannelSpace?
    public var viewInfo: [ViewInfo]
    public var fieldInfo: [FieldInfo]
    public var icon: String
    public var lastViewInfo: LastViewInfo
    public var isGeneral: Bool
    public var belongTo: String
//    let memberIDS: JSONNull?
    public var channelType: ChannelType

    enum CodingKeys: String, CodingKey {
        case groupID = "groupId"
        case ownerID = "ownerId"
        case name, isWorkspacePublic, channelSpace, viewInfo, fieldInfo, icon, lastViewInfo, isGeneral, belongTo, channelType
//        case memberIDS = "memberIds"
    }
}

extension GroupData: Identifiable {
    public var id: String { groupID }
}


extension GroupData {
    public enum ChannelType: String, Codable, Hashable {
        case database = "database"
        case post = "post"
    }
    
    public struct ChannelSpace: Codable, Hashable {
        public let bgURL: String
        public let bioDescription: String?
        public let position: Int

        enum CodingKeys: String, CodingKey {
            case bgURL = "bgUrl"
            case bioDescription, position
        }
    }
    
    public struct LastViewInfo: Codable, Hashable {
        public var unreadCount: Int
        public var lastACKTrickleID: Double?
        public var lastACKTrickleCreateAt: Int
        public var createAt, updateAt: Date?
        
        enum CodingKeys: String, CodingKey {
            case unreadCount
            case lastACKTrickleID = "lastAckTrickleId"
            case lastACKTrickleCreateAt = "lastAckTrickleCreateAt"
            case createAt, updateAt
        }
    }
}

public struct FieldOptions: Codable, Hashable {
    public let fieldID: String
    public let fieldOptionInfo: [FieldOptionInfo]
    
    enum CodingKeys: String, CodingKey {
        case fieldID = "fieldId"
        case fieldOptionInfo
    }
    
    public struct FieldOptionInfo: Codable, Hashable, Identifiable {
        public let fieldOptionID, value: String
        public let color: FieldOptionColor
        
        enum CodingKeys: String, CodingKey {
            case fieldOptionID = "fieldOptionId"
            case color, value
        }
        
        public var id: String {
            fieldOptionID
        }
    }
}

extension FieldOptions.FieldOptionInfo {
    public enum FieldOptionColor: String, Codable, Hashable {
        case red, green, yellow, blue, orange, pink, purple, gray
        
        public init(from decoder: Decoder) throws {
            self = try FieldOptionColor(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .gray
        }
    }
}

public typealias FieldsOptions = [FieldOptions]



