//
//  CommentData.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/3.
//

import Foundation

public struct CommentData: Codable, Hashable {
    public var commentID: String
    public var typ: CommentType?
    public var text: Text?
    public var blocks: [TrickleData.Block]?
    public var hasQuoted: Bool?
    public var commentAuthor: MemberData
    public var mentionedMemberInfo: [MemberData]?
    public var quoteCommentInfo: QuoteCommentData?
    public var reactionInfo: [ReactionData]?
    public var createAt, updateAt: Date
    
    enum CodingKeys: String, CodingKey {
        case typ, text, blocks
        case commentID = "commentId"
        case hasQuoted, commentAuthor, mentionedMemberInfo, quoteCommentInfo, reactionInfo, createAt, updateAt
    }
    
    var quoted: QuoteCommentData {
        QuoteCommentData(commentID: commentID,
                         typ: typ ?? .normal,
                         text: .init(),
                         blocks: blocks ?? [],
                         hasQuoted: false,
                         commentAuthor: commentAuthor,
                         createAt: createAt,
                         updateAt: updateAt)
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
        public let commentID: String
        public let typ: CommentType
        public let text: QuoteCommentDataText
        public let blocks: [TrickleData.Block]
        public let hasQuoted: Bool
        public let commentAuthor: MemberData
        public let createAt, updateAt: Date

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
