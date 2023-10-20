//
//  File.swift
//  
//
//  Created by Chocoford on 2023/7/19.
//

import Foundation
extension TrickleBlock {
    public struct ListBlock: TrickleContentBlockData {
        public var id: String
        public var type: TrickleBlock.BlockType
        public var isFirst: Bool?
        public var indent: Int
        public var userDeinfedValue: String?
        public var elements: [TrickleElement]
        
        public init(
            id: String = UUID().uuidString,
                    type: TrickleBlock.BlockType,
                    isFirst: Bool? = nil,
                    indent: Int,
                    userDeinfedValue: String? = nil,
                    elements: [TrickleElement]
        ) {
            self.id = id
            self.type = type
            self.isFirst = isFirst
            self.indent = indent
            self.userDeinfedValue = userDeinfedValue
            self.elements = elements
        }
    }
}
