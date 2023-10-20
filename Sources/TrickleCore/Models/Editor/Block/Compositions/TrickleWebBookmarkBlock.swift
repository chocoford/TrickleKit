//
//  File.swift
//  
//
//  Created by Chocoford on 2023/7/19.
//

import Foundation
extension TrickleBlock {
    public struct WebBookmarkBlock: TrickleBlockData {
        public var id: String
        public var type: TrickleBlock.BlockType
        public var indent: Int
        public var userDefinedValue: WebBookmarkBlockValue
    }
}
