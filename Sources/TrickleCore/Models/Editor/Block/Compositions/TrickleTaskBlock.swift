//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/7/19.
//

import Foundation
extension TrickleBlock {
    public struct TaskBlock: TrickleNestableBlockData {
        public var id: String
        public var type: TrickleBlock.BlockType
        public var indent: Int
        public var blocks: [TrickleBlock]
        
        public init(
            id: String = UUID().uuidString,
            indent: Int = 0,
            blocks: [TrickleBlock]
        ) {
            self.id = id
            self.type = .todos
            self.indent = indent
            self.blocks = blocks
        }
    }
}
