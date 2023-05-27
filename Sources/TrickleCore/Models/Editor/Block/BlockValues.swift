//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/27.
//

import Foundation

// MARK: - Checkbox Block
extension TrickleData.Block {
    public struct CheckboxBlockValue: Codable, Hashable {
        public let status: CheckboxStatus
        public let operatorID: String?
        
        enum CodingKeys: String, CodingKey {
            case status
            case operatorID = "operatorId"
        }
        
        public enum CheckboxStatus: String, Codable {
            case unchecked, indeterminate, checked
        }
        
        public init(status: CheckboxStatus, operatorID: String? = nil) {
            self.status = status
            self.operatorID = operatorID
        }
    }
}

//MARK: - Code Block
extension TrickleData.Block {
    public struct CodeBlockValue: Codable, Hashable {
        public var language: String
        
        public init(language: String) {
            self.language = language
        }
    }
}


//MARK: - File Block
extension TrickleData.Block {
    public struct FileBlockValue: Codable, Hashable {
        public var url: URL
        public var name: String
        public var size: String
        
        public init(url: URL, name: String, size: String) {
            self.url = url
            self.name = name
            self.size = size
        }
    }
}

//MARK: - Embed Block
extension TrickleData.Block {
    public struct EmbedBlockValue: Codable, Hashable {
        public let src: String
        public let height: String?
        
        public init(src: String, height: String? = nil) {
            self.src = src
            self.height = height
        }
    }
}


//MARK: - Web Bookmark
extension TrickleData.Block {
    public struct WebBookmarkBlockValue: Codable, Hashable {
        public var url: URL
        
        public init(url: URL) {
            self.url = url
        }
    }
}

