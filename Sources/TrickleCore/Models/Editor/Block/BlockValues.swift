//
//  File.swift
//  
//
//  Created by Chocoford on 2023/5/27.
//

import Foundation

extension TrickleBlock {
    //MARK: - Web Bookmark
    public struct WebBookmarkBlockValue: Codable, Hashable {
        public var url: URL?
        
        public init(url: URL) {
            self.url = url
        }
        
        public init(from decoder: Decoder) throws {
            let singleContainer = try decoder.singleValueContainer()
            if let x = try? singleContainer.decode(String.self) {
                self.url = URL(string: x)
                return
            }
            
            let container: KeyedDecodingContainer<TrickleBlock.WebBookmarkBlockValue.CodingKeys> = try decoder.container(keyedBy: TrickleBlock.WebBookmarkBlockValue.CodingKeys.self)
            if let url = try? container.decode(URL.self, forKey: TrickleBlock.WebBookmarkBlockValue.CodingKeys.url) {
                self.url = url
            } else {
                self.url = nil
            }
        }
    }
    
    // MARK: - Vote
    public typealias VoteBlockValue = [String : [String]]
}

