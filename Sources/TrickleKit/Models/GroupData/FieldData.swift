//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/2.
//

import Foundation


extension GroupData {
    public struct FieldInfo: Codable, Hashable, Identifiable {
        public let fieldID, name: String
        public let display: Bool
        public let type: FieldType
        public let icon: String?
        public let extraData: ExtraData?
        //        let defaultValue: JSONNull?
        public let fieldInfoRequired: Bool
        
        enum CodingKeys: String, CodingKey {
            case fieldID = "fieldId"
            case name, display, type, icon
            case fieldInfoRequired = "required"
            case extraData//, defaultValue
        }
        
        public var id: String {
            fieldID
        }
    }
}
    

extension GroupData.FieldInfo {
    // MARK: - ExtraData
    public struct ExtraData: Codable, Hashable {
        public let dateFormat, timeFormat, numberLayout: Int?
        public let numberLayoutBarColor: NumberLayoutBarColor?
        public let numberLayoutWithNumber: Bool?
    }
    
    
    public enum FieldType: String, Codable {
        case title, createAt, updateAt, progress
        case createBy = "create_by"
        case createOn = "create_on"
        case lastEditBy = "last_edit_by"
        case lastEditOn = "last_edit_on"
        case text, number, date
        case singleSelect = "single_select"
        case multiSelect = "multi_select"
        case people, url, checkbox, relation, placeholder
        
        var isMulti: Bool {
            switch self {
                case .people, .multiSelect:
                    return true
                default:
                    return false
            }
        }
    }
}

extension GroupData.FieldInfo.ExtraData {
    public enum NumberLayoutBarColor: String, Codable {
        case green = "green"
    }
}
