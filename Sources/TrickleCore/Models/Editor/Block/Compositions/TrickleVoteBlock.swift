//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/7/19.
//

import Foundation
extension TrickleBlock {
    public struct VoteBlock: TrickleNestableBlockData {
        public var id: String
        public var type: TrickleBlock.BlockType
        public var indent: Int
        public var blocks: [TrickleBlock]
        public var userDefinedValue: VoteBlockValue
        
        public init(
            id: String = UUID().uuidString,
            indent: Int = 0,
            blocks: [TrickleBlock],
            userDefinedValue: VoteBlockValue
        ) {
            self.id = id
            self.type = .vote
            self.indent = indent
            self.blocks = blocks
            self.userDefinedValue = userDefinedValue
        }
    }
}
