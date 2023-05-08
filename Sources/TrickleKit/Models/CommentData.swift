//
//  CommentData.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/3.
//

import Foundation

public struct CommentData: Codable, Hashable {
    public let commentID: String
    public let typ: CommentType?
    public let text: Text?
    public let blocks: [TrickleData.Block]?
    public let hasQuoted: Bool
    public let commentAuthor: MemberData
    public let mentionedMemberInfo: [MemberData]
    public let quoteCommentInfo: QuoteCommentData?
    public let reactionInfo: [ReactionData]?
    public let createAt, updateAt: Date
    
    enum CodingKeys: String, CodingKey {
        case typ, text, blocks
        case commentID = "commentId"
        case hasQuoted, commentAuthor, mentionedMemberInfo, quoteCommentInfo, reactionInfo, createAt, updateAt
    }
}

extension CommentData: Identifiable {
    public var id: String { commentID }
}


extension CommentData {
    public enum CommentType: String, Codable {
        case normal = "normal"
        case system = "system"
    }
    
    public struct Text: Codable, Hashable {
        public let en, zh: String?
    }

    public struct QuoteCommentData: Codable, Hashable {
        public let typ: CommentType
        public let text: QuoteCommentDataText
        public let blocks: [TrickleData.Block]
        public let createAt, updateAt: Int
        public let commentID: String
        public let hasQuoted: Bool
        public let commentAuthor: MemberData

        enum CodingKeys: String, CodingKey {
            case typ, text, blocks, createAt, updateAt
            case commentID = "commentId"
            case hasQuoted, commentAuthor
        }
    }
    
    
}


extension CommentData.QuoteCommentData {
    public struct QuoteCommentDataText: Codable, Hashable {}
}
