//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/7/19.
//

import Foundation
extension TrickleBlock {
    public struct EmbedBlock: TrickleBlockData {
        public var id: String
        public var type: TrickleBlock.BlockType
        public var indent: Int
        public var userDefinedValue: EmbedBlockValue
        
        public init(id: String = UUID().uuidString,
                    indent: Int = 0,
                    userDefinedValue: EmbedBlockValue) {
            self.id = id
            self.type = .embed
            self.indent = indent
            self.userDefinedValue = userDefinedValue
        }
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<TrickleBlock.EmbedBlock.CodingKeys> = try decoder.container(keyedBy: TrickleBlock.EmbedBlock.CodingKeys.self)
            self.id = try container.decode(String.self, forKey: TrickleBlock.EmbedBlock.CodingKeys.id)
            self.type = try container.decode(TrickleBlock.BlockType.self, forKey: TrickleBlock.EmbedBlock.CodingKeys.type)
            self.indent = try container.decode(Int.self, forKey: TrickleBlock.EmbedBlock.CodingKeys.indent)
            if let onlySrc = try? container.decode(String.self, forKey: TrickleBlock.EmbedBlock.CodingKeys.userDefinedValue) {
                self.userDefinedValue = .init(src: onlySrc)
            } else {
                self.userDefinedValue = try container.decode(TrickleBlock.EmbedBlockValue.self, forKey: TrickleBlock.EmbedBlock.CodingKeys.userDefinedValue)
            }
            
        }
    }
    
    public struct EmbedBlockValue: Codable, Hashable {
        public let src: String
        public let height: Int?
        
        public init(src: String, height: Int = 400) {
            self.src = src
            self.height = height
        }
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<TrickleBlock.EmbedBlockValue.CodingKeys> = try decoder.container(keyedBy: TrickleBlock.EmbedBlockValue.CodingKeys.self)
            self.src = try container.decode(String.self, forKey: TrickleBlock.EmbedBlockValue.CodingKeys.src)
            if let heightString = try? container.decodeIfPresent(String.self, forKey: TrickleBlock.EmbedBlockValue.CodingKeys.height) {
                self.height = Int(heightString)
            } else {
                self.height = try container.decodeIfPresent(Int.self, forKey: TrickleBlock.EmbedBlockValue.CodingKeys.height)
            }
        }
    }
}
