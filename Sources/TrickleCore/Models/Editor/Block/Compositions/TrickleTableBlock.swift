//
//  TrickleTableBlock.swift
//
//
//  Created by Chocoford on 2023/8/17.
//

import Foundation

extension TrickleBlock {
    public struct TableBlock: TrickleBlockData {
        public var id: String
        public var type: TrickleBlock.BlockType
        public var indent: Int
        public var userDefinedValue: TableBlockValue
        
        public init(id: String = UUID().uuidString, indent: Int = 0, userDefinedValue: TableBlockValue) {
            self.id = id
            self.type = .table
            self.indent = indent
            self.userDefinedValue = userDefinedValue
            
        }
        
        
        public struct TableBlockValue: Codable, Hashable {
            public var withHeadings: Bool
            public var content: [[String]]
            
            public init(withHeadings: Bool, content: [[String]]) {
                self.withHeadings = withHeadings
                self.content = content
            }
        }
    }
}
