//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/2.
//

import Foundation

extension GroupData {
    public struct ViewInfo: Codable, Hashable, Identifiable {
        public let viewID: String
        public let name: String
        public let type: ViewInfoType
        public let sorts: [NextQuery.Sort]?
        public let filters: [FilterData]?
        public let fieldSettings: [FieldSetting]
        public let groupBy: GroupByData?
        public let openPageMode: Int
        public let isDefault: Bool
        public let filterLogicalOperator: FilterLogicalOperator?
        
        enum CodingKeys: String, CodingKey {
            case viewID = "viewId"
            case name, type, sorts, fieldSettings, openPageMode, isDefault, groupBy, filters, filterLogicalOperator
        }
        
        public var id: String { viewID }
    }
}


extension GroupData.ViewInfo {
    public enum ViewInfoType: String, Codable {
        case feed = "feed"
        case files = "files"
        case list = "list"
        case kanban = "kanban"
    }
    
    public struct FieldSetting: Codable, Hashable {
        public let fieldID: GroupData.FieldInfo.ID
        public let ranks: String
        public let width: Int?
        public let display: Bool
        public let createAt, updateAt: Date?

        enum CodingKeys: String, CodingKey {
            case fieldID = "fieldId"
            case ranks, width, display, createAt, updateAt
        }
    }
    
    public struct GroupByData: Codable, Hashable {
        public let fieldID: String
        public let type: GroupData.FieldInfo.FieldType
        public let hiddenGroups: [String]
        public let visibleGroups: [String]

        enum CodingKeys: String, CodingKey {
            case type
            case fieldID = "fieldId"
            case hiddenGroups, visibleGroups
        }
    }
    
    public struct FilterData: Codable, Hashable {
        public let fieldID: GroupData.FieldInfo.ID
        public let type: GroupData.FieldInfo.FieldType
        public let value: TrickleData.FieldDatumValue
        public let operatorID: String?
        public let filterOperator: FilterOperator
        
        enum CodingKeys: String, CodingKey {
            case type, value
            case fieldID = "fieldId"
            case filterOperator = "operator"
            case operatorID = "operatorId"
        }
    }
    
    public enum FilterLogicalOperator: String, Codable, Hashable {
        case and = "AND"
        case or = "OR"
    }
    
    public enum FilterOperator: String, Codable, Hashable {
        case contains
        case gt
        case eq
        case neq
        case lt
        case gte
        case lte
        case inRange
        case notInRange
        case isNull
        case isNotNull
        case notContains
        case startsWith
        case endsWith
        case isChecked
        case isUnChecked
    }
}

extension GroupData.ViewInfo.FilterData {
    public enum FilterDataValue: Codable, Hashable {
        case string(String)
        case strings([String])
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            if let v = try? container.decode(String.self) {
                self = .string(v)
                return
            }
            if let v = try? container.decode([String].self) {
                self = .strings(v)
                return
            }
            throw DecodingError.typeMismatch(
                FilterDataValue.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "[FilterDataValue] Type is not matched", underlyingError: nil))
        }
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
                case .string(let value):
                    try container.encode(value)
                case .strings(let value):
                    try container.encode(value)
            }
        }
    }
}


// MARK: - View Info Relavant

public struct GroupViewTricklesStat: Codable, Hashable {
    public let stats: [StatValue]
    
    public struct StatValue: Codable, Hashable {
        public let groupID: GroupData.FieldInfo.ID
        public let counts: Int

        enum CodingKeys: String, CodingKey {
            case groupID = "groupId"
            case counts
        }
    }
    
    static var empty: GroupViewTricklesStat = .init(stats: [
        .init(groupID: "NULL", counts: 0)
    ])
}
