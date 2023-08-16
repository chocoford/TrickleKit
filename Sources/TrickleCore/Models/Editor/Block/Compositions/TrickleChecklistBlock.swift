//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/7/19.
//

import Foundation

extension TrickleBlock {
    public struct ChecklistBlock: TrickleContentBlockData {
        public var id: String
        public var type: TrickleBlock.BlockType
        public var indent: Int
        public var elements: [TrickleElement]
        public var userDefinedValue: CheckboxBlockValue?
        
        public init(
            id: String = UUID().uuidString,
            indent: Int = 0,
            elements: [TrickleElement],
            userDefinedValue: CheckboxBlockValue
        ) {
            self.id = id
            self.type = .checkbox
            self.indent = indent
            self.elements = elements
            self.userDefinedValue = userDefinedValue
        }
        
        
    }
    
    public struct CheckboxBlockValue: Codable, Hashable {
        public let status: CheckboxStatus
        public let operatorID: String?
        
        enum CodingKeys: String, CodingKey {
            case status
            case operatorID = "operatorId"
        }
        
        public enum CheckboxStatus: String, Codable {
            case unchecked, indeterminate, checked
        }
        
        public init(status: CheckboxStatus, operatorID: String? = nil) {
            self.status = status
            self.operatorID = operatorID
        }
        
        public init(from decoder: Decoder) throws {
            let singleContainer = try decoder.singleValueContainer()
            if let x = try? singleContainer.decode(String.self) {
                self.status = x == "checked" ? .checked : .unchecked
                self.operatorID = nil
                return
            }
            
            let container: KeyedDecodingContainer<TrickleBlock.CheckboxBlockValue.CodingKeys> = try decoder.container(keyedBy: TrickleBlock.CheckboxBlockValue.CodingKeys.self)
            self.status = try container.decode(TrickleBlock.CheckboxBlockValue.CheckboxStatus.self, forKey: TrickleBlock.CheckboxBlockValue.CodingKeys.status)
            self.operatorID = try container.decodeIfPresent(String.self, forKey: TrickleBlock.CheckboxBlockValue.CodingKeys.operatorID)
        }
        
        public static var unchecked: CheckboxBlockValue { .init(status: .unchecked) }
    }
}
