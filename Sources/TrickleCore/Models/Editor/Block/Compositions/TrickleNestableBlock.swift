//
//  File.swift
//  
//
//  Created by Chocoford on 2023/7/19.
//

import Foundation

extension TrickleBlock {
    public struct NestableBlock: TrickleNestableBlockData {
        public var id: String
        public var type: TrickleBlock.BlockType
        public var indent: Int
        public var blocks: [TrickleBlock]
        
        public init(
            id: String = UUID().uuidString,
            type: TrickleBlock.BlockType,
            indent: Int = 0,
            blocks: [TrickleBlock]
        ) {
            self.id = id
            self.type = type
            self.indent = indent
            self.blocks = blocks
        }
    }
}
