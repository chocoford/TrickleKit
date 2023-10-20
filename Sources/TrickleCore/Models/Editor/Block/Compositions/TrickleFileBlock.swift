//
//  File.swift
//  
//
//  Created by Chocoford on 2023/7/19.
//

import Foundation

extension TrickleBlock {
    public struct FileBlock: TrickleBlockData {
        public var id: String
        public var type: TrickleBlock.BlockType
        public var indent: Int
        public var userDefinedValue: FileBlockValue
        
        public init(id: String = UUID().uuidString,
                    indent: Int = 0,
                    userDefinedValue: FileBlockValue) {
            self.id = id
            self.type = .file
            self.indent = indent
            self.userDefinedValue = userDefinedValue
        }
    }
    
    public struct FileBlockValue: Codable, Hashable {
        public var url: URL?
        public var name: String?
        public var size: String?
        public var status: Status?
        
        public init(url: URL, name: String, size: String, status: Status = .uploaded) {
            self.url = url
            self.name = name
            self.size = size
            self.status = status
        }
        
        public enum Status: String, Codable {
            case uploaded
        }
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<TrickleBlock.FileBlockValue.CodingKeys> = try decoder.container(keyedBy: TrickleBlock.FileBlockValue.CodingKeys.self)
            if let url = try? container.decode(URL.self, forKey: TrickleBlock.FileBlockValue.CodingKeys.url) {
                self.url = url
            } else {
                self.url = nil
            }
            self.name = try container.decodeIfPresent(String.self, forKey: TrickleBlock.FileBlockValue.CodingKeys.name)
            self.size = try container.decodeIfPresent(String.self, forKey: TrickleBlock.FileBlockValue.CodingKeys.size)
            self.status = try container.decodeIfPresent(TrickleBlock.FileBlockValue.Status.self, forKey: TrickleBlock.FileBlockValue.CodingKeys.status)
        }
    }
}
