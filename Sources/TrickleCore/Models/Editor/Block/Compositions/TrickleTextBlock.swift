//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/7/19.
//

import Foundation

extension TrickleBlock {
    public struct TextBlock: TrickleContentBlockData {
        public var id: String = UUID().uuidString
        public var type: TrickleBlock.BlockType = .richText
        public var indent: Int = 0
        public var elements: [TrickleElement]
        
        public init(id: String = UUID().uuidString, indent: Int = 0, elements: [TrickleElement]) {
            self.id = id
            self.type = .richText
            self.indent = indent
            self.elements = elements
        }
    }
}
