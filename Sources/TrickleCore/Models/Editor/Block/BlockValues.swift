//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/27.
//

import Foundation

extension TrickleBlock {
    //MARK: - Web Bookmark
    public struct WebBookmarkBlockValue: Codable, Hashable {
        public var url: URL
        
        public init(url: URL) {
            self.url = url
        }
    }
    
    // MARK: - Vote
    public typealias VoteBlockValue = [String : [String]]
}

