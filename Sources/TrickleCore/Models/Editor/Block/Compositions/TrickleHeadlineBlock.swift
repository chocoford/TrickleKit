//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/7/19.
//

import Foundation
extension TrickleBlock {
    public struct HeadlineBlock: TrickleContentBlockData {
        public var id: String
        public var type: TrickleBlock.BlockType
        public var indent: Int
        public var elements: [TrickleElement]
        
        public init(
            id: String = UUID().uuidString,
            type: TrickleBlock.BlockType,
            indent: Int = 0,
            elements: [TrickleElement]
        ) {
            self.id = id
            self.type = type
            self.indent = indent
            self.elements = elements
        }
        
        public init(
            id: String = UUID().uuidString,
            type: TrickleBlock.BlockType,
            indent: Int = 0,
            text: String
        ) {
            self.id = id
            self.type = type
            self.indent = indent
            self.elements = [.text(.init(text: text))]
        }
    }
}
