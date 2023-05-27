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
        let status: CheckboxStatus
        let operatorID: String?
        
        enum CodingKeys: String, CodingKey {
            case status
            case operatorID = "operatorId"
        }
        
        enum CheckboxStatus: String, Codable {
            case unchecked, indeterminate, checked
        }
    }
}

//MARK: - Code Block
extension TrickleData.Block {
    public struct CodeBlockValue: Codable, Hashable {
        var language: String
    }
}


//MARK: - File Block
extension TrickleData.Block {
    public struct FileBlockValue: Codable, Hashable {
        var url: URL
        var name: String
        var size: String
    }
}

//MARK: - Embed Block
extension TrickleData.Block {
    public struct EmbedBlockValue: Codable, Hashable {
        let src: String
        let height: String?
    }
}


//MARK: - Web Bookmark
extension TrickleData.Block {
    public struct WebBookmarkBlockValue: Codable, Hashable {
        var url: URL
    }
}

