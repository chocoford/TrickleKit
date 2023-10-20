//
//  TrickleProgressBlock.swift
//  
//
//  Created by Chocoford on 2023/7/19.
//

import Foundation
extension TrickleBlock {
    public struct ProgressBlock: TrickleBlockData {
        public var id: String
        public var type: TrickleBlock.BlockType
        public var indent: Int
        public var userDefinedValue: ProgressBlockValue
        
        public init(
            id: String = UUID().uuidString,
            indent: Int = 0,
            userDefinedValue: ProgressBlockValue
        ) {
            self.id = id
            self.type = .progress
            self.indent = indent
            self.userDefinedValue = userDefinedValue
        }
    }
    
    
    public struct ProgressBlockValue: Codable, Hashable {
        public var progress: Double
    }
}
