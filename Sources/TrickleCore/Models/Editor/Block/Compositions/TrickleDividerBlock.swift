//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/7/19.
//

import Foundation

extension TrickleBlock {
    public struct DividerBlock: TrickleBlockData {
        public var id: String
        public var type: TrickleBlock.BlockType
        public var indent: Int
    }
}

