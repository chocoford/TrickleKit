//
//  File 2.swift
//  
//
//  Created by Dove Zachary on 2023/7/19.
//

import Foundation

extension TrickleBlock {
    public struct ReferenceBlock: TrickleBlockData {
        public var id: String
        public var type: TrickleBlock.BlockType
        public var indent: Int
        
        init(id: String = UUID().uuidString, indent: Int) {
            self.id = id
            self.type = .reference
            self.indent = indent
        }
    }
}
