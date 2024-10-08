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
    
    public init(team: [GroupData], personal: [GroupData]) {
        self.team = team
        self.personal = personal
    }
}

public struct WorkspaceMemoryGroupsData: Codable, Hashable {
    public let team: GroupData
    public let personal: GroupData
    
    public init(team: GroupData, personal: GroupData) {
        self.team = team
        self.personal = personal
    }
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
    
    public init(groupID: String, ownerID: String, name: String, isWorkspacePublic: Bool, channelSpace: ChannelSpace? = nil, viewInfo: [ViewInfo], fieldInfo: [FieldInfo], icon: String, lastViewInfo: LastViewInfo, isGeneral: Bool, belongTo: String, channelType: ChannelType) {
        self.groupID = groupID
        self.ownerID = ownerID
        self.name = name
        self.isWorkspacePublic = isWorkspacePublic
        self.channelSpace = channelSpace
        self.viewInfo = viewInfo
        self.fieldInfo = fieldInfo
        self.icon = icon
        self.lastViewInfo = lastViewInfo
        self.isGeneral = isGeneral
        self.belongTo = belongTo
        self.channelType = channelType
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
        public var lastACKTrickleID: Double? // bug in backend
        public var lastACKTrickleCreateAt: Date
        public var createAt, updateAt: Date?
        
        enum CodingKeys: String, CodingKey {
            case unreadCount
            case lastACKTrickleID = "lastAckTrickleId"
            case lastACKTrickleCreateAt = "lastAckTrickleCreateAt"
            case createAt, updateAt
        }
        
        public init(
            unreadCount: Int,
            lastACKTrickleID: Double? = nil,
            lastACKTrickleCreateAt: Date,
            createAt: Date? = nil,
            updateAt: Date? = nil
        ) {
            self.unreadCount = unreadCount
            self.lastACKTrickleID = lastACKTrickleID
            self.lastACKTrickleCreateAt = lastACKTrickleCreateAt
            self.createAt = createAt
            self.updateAt = updateAt
        }
    }
}

public struct FieldOptions: Codable, Hashable, Identifiable  {
    public let fieldID: String
    public let options: [FieldOptionInfo]
    
    enum CodingKeys: String, CodingKey {
        case fieldID = "fieldId"
        case options = "fieldOptionInfo"
    }
    
    public var id: String { fieldID }
}

extension FieldOptions {
    public struct FieldOptionInfo: Codable, Hashable, Identifiable {
        public let fieldOptionID, value: String
        public let color: FieldOptionColor
        
        enum CodingKeys: String, CodingKey {
            case fieldOptionID = "fieldOptionId"
            case color, value
        }
        
        public var id: String { fieldOptionID }
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



