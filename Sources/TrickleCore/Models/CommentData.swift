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
    public var blocks: [TrickleBlock]?
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
    
    public var quoted: QuoteCommentData {
        QuoteCommentData(commentID: commentID,
                         typ: typ ?? .normal,
                         text: .init(),
                         blocks: blocks ?? [],
                         hasQuoted: false,
                         commentAuthor: commentAuthor,
                         createAt: createAt,
                         updateAt: updateAt)
    }
    
    public init(commentID: String,
                typ: CommentType?,
                text: Text?,
                blocks: [TrickleBlock]?,
                hasQuoted: Bool = false,
                commentAuthor: MemberData,
                mentionedMemberInfo: [MemberData],
                quoteCommentInfo: QuoteCommentData?,
                reactionInfo: [ReactionData],
                createAt: Date,
                updateAt: Date) {
        self.commentID = commentID
        self.typ = typ
        self.text = text
        self.blocks = blocks
        self.hasQuoted = hasQuoted
        self.commentAuthor = commentAuthor
        self.mentionedMemberInfo = mentionedMemberInfo
        self.quoteCommentInfo = quoteCommentInfo
        self.reactionInfo = reactionInfo
        self.createAt = createAt
        self.updateAt = updateAt
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
        public let blocks: [TrickleBlock]
        public let hasQuoted: Bool?
        public let commentAuthor: MemberData
        public let createAt, updateAt: Date

        enum CodingKeys: String, CodingKey {
            case typ, text, blocks, createAt, updateAt
            case commentID = "commentId"
            case hasQuoted, commentAuthor
        }
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CommentData.QuoteCommentData.CodingKeys> = try decoder.container(keyedBy: CommentData.QuoteCommentData.CodingKeys.self)
            self.typ = try container.decode(CommentData.CommentType.self, forKey: CommentData.QuoteCommentData.CodingKeys.typ)
            self.text = try container.decode(CommentData.QuoteCommentData.QuoteCommentDataText.self, forKey: CommentData.QuoteCommentData.CodingKeys.text)
            self.blocks = try container.decode([TrickleBlock].self, forKey: CommentData.QuoteCommentData.CodingKeys.blocks)
            if let dirtyCreateAt = try? container.decode([Date].self, forKey: CommentData.QuoteCommentData.CodingKeys.createAt) {
                self.createAt = dirtyCreateAt.first ?? .distantPast
            } else {
                self.createAt = try container.decode(Date.self, forKey: CommentData.QuoteCommentData.CodingKeys.createAt)
            }
            if let dirtyUpdateeAt = try? container.decode([Date].self, forKey: CommentData.QuoteCommentData.CodingKeys.updateAt) {
                self.updateAt = dirtyUpdateeAt.first ?? .distantPast
            } else {
                self.updateAt = try container.decode(Date.self, forKey: CommentData.QuoteCommentData.CodingKeys.updateAt)
            }
            self.commentID = try container.decode(String.self, forKey: CommentData.QuoteCommentData.CodingKeys.commentID)
            self.hasQuoted = try container.decodeIfPresent(Bool.self, forKey: CommentData.QuoteCommentData.CodingKeys.hasQuoted)
            self.commentAuthor = try container.decode(MemberData.self, forKey: CommentData.QuoteCommentData.CodingKeys.commentAuthor)
        }
        
        public init(commentID: String, typ: CommentType, text: QuoteCommentDataText, blocks: [TrickleBlock], hasQuoted: Bool, commentAuthor: MemberData, createAt: Date, updateAt: Date) {
            self.commentID = commentID
            self.typ = typ
            self.text = text
            self.blocks = blocks
            self.hasQuoted = hasQuoted
            self.commentAuthor = commentAuthor
            self.createAt = createAt
            self.updateAt = updateAt
        }
    }
}

extension CommentData.QuoteCommentData {
    public struct QuoteCommentDataText: Codable, Hashable {}
}
