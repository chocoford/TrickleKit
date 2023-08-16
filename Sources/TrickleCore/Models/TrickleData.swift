//
//  TrickleIntergratable.swift
//  TrickleKit
//
//  Created by Chocoford on 2022/12/6.
//

import Foundation

// MARK: - TrickleData
public struct TrickleData: Codable, Hashable {
    public var trickleID: String
    public var allowGuestMemberComment, allowGuestMemberReact: Bool
    public var allowWorkspaceMemberComment, allowWorkspaceMemberReact: Bool
    public var authorMemberInfo: MemberData
    public var authorAppMemberInfo: MemberData?
    public var blocks: [TrickleBlock]
    public var commentInfo: [CommentData]?
    public var commentCounts: Int
    public var editBy: MemberData?
    public var hasStarred, isPinned, isPublic: Bool
    public var lastViewInfo: LastViewData
    public var mentionedMemberInfo: [MentionedMemberData]?
    public var reactionInfo: [ReactionData]
    public var groupInfo: GroupData
    public var referInfo: ReferData?
    public var title: String
    public var threadID: String?
    public var createAt: Date
    public var updateAt, editAt: Date?
    public var userDefinedTitle: String?
    public var viewedMemberInfo: ViewedMemberData
    public var editingMemberInfo: [MemberData]
    public var fieldData: [String: FieldDatumValue]?
    
    // Local info
//    public var localProperties: LocalProperties?
    
    enum CodingKeys: String, CodingKey {
        case trickleID = "trickleId"
        case allowGuestMemberComment, allowGuestMemberReact, allowWorkspaceMemberComment, allowWorkspaceMemberReact, authorAppMemberInfo, authorMemberInfo, blocks, commentInfo, commentCounts, createAt, editAt, editBy, hasStarred, isPinned, isPublic, lastViewInfo, mentionedMemberInfo, reactionInfo, groupInfo, referInfo, title
        case threadID = "threadId"
        case updateAt, userDefinedTitle, viewedMemberInfo, editingMemberInfo, fieldData
//        case localProperties
    }
}

extension TrickleData: Identifiable {
    public var id: String {
        trickleID
    }
}

extension TrickleData {
    public struct LocalProperties: Codable, Hashable {
        var localSent: Bool
        
        public init(localSent: Bool) {
            self.localSent = localSent
        }
    }
}

// MARK: Userful tools
extension TrickleData {
    /// The title calculated for display.
    var displayedTitle: String {
        if let title = self.userDefinedTitle,
            title.replacingOccurrences(of: " ", with: "").count > 0 {
            return title
        } else if self.title.replacingOccurrences(of: " ", with: "").count > 0 {
            return title
        } else {
            return String(blocks.map { block in
                switch block {
                    case .code:
                        return "[Code Block]"
                    case .gallery:
                        return "[Gallery]"
                    case .reference:
                        return "[Reference]"
                    case .embed:
                        return "[Embed Block]"
                    default:
                        return (block.elements ?? []).map { element in
                            element.text
                        }.joined()
                }
            }.joined(separator: "\n").prefix(20))
        }
    }
}

extension TrickleData {
    public struct ReferData: Codable, Hashable {}
    public struct ViewedMemberData: Codable, Hashable {
        public var counts: Int
        public var members: [MemberData]
        
        public init(counts: Int, members: [MemberData]) {
            self.counts = counts
            self.members = members
        }
    }
    public struct LastViewData: Codable, Hashable {
        public var unreadCount: Int?
        public var lastViewedAt: Date?
        public var lastACKMessageID: CommentData.ID?
        public var lastACKMessageCreateAt: Date?

        enum CodingKeys: String, CodingKey {
            case unreadCount, lastViewedAt
            case lastACKMessageID = "lastAckMessageId"
            case lastACKMessageCreateAt = "lastAckMessageCreateAt"
        }
    }
    public struct GroupData: Codable, Hashable {
        public let groupID, ranks: String?
        
        enum CodingKeys: String, CodingKey {
            case groupID = "groupId"
            case ranks
        }
    }
    public struct MentionedMemberData: Codable, Hashable {
        let memberID: String
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
        }
    }
    
    // MARK: - Field Data
    public enum FieldDatumValue: Codable, Hashable {
        case int(Int)
        case double(Double)
        case string(String)
        case strings([String])
        case relations([RelationData])
        case null

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode(Int.self) {
                self = .int(x)
                return
            }
            if let x = try? container.decode(Double.self) {
                self = .double(x)
                return
            }
            if let x = try? container.decode(String.self) {
                self = .string(x)
                return
            }
            if let x = try? container.decode([String].self) {
                self = .strings(x)
                return
            }
            if let x = try? container.decode([RelationData].self) {
                self = .relations(x)
                return
            }
            if container.decodeNil() {
                self = .null
                return
            }
            throw DecodingError.typeMismatch(FieldDatumValue.self,
                                             DecodingError.Context(codingPath: decoder.codingPath,
                                                                   debugDescription: "Wrong type for FieldDatumValue"))
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
                case .int(let x):
                    try container.encode(x)
                case .double(let x):
                    try container.encode(x)
                case .string(let x):
                    try container.encode(x)
                case .strings(let x):
                    try container.encode(x)
                case .relations(let x):
                    try container.encode(x)
                case .null:
                    try container.encodeNil()
            }
        }
    }

    public struct RelationData: Codable, Hashable {
        public let title, trickleID: String
 public let userDefinedTitle: String?

        enum CodingKeys: String, CodingKey {
            case title
            case trickleID = "trickleId"
            case userDefinedTitle
        }
    }
    
    // MARK: - Editor
//    public struct Block: Codable, Hashable, Identifiable {
//        public let id: String
//        public var type: BlockType
//        public var isFirst: Bool?
//        public var indent: Int
//        public var blocks: [Block]?
//        public var elements: [Element]?
//        public var userDefinedValue: UserDefinedValue?
//        
//        private init(type: BlockType, value: UserDefinedValue? = nil, blocks: [Block]?, elements: [Element]?) {
//            self.id = UUID().uuidString
//            self.type = type
//            self.isFirst = true
//            self.indent = 0
//            self.blocks = blocks
//            self.elements = elements
//            self.userDefinedValue = value
//        }
//        
//        public init(type: BlockType, value: UserDefinedValue? = nil, elements: [Element]) {
//            self.init(type: type, value: value, blocks: nil, elements: elements)
//        }
//        
//        public init(type: BlockType, value: UserDefinedValue? = nil, blocks: [Block]) {
//            self.init(type: type, value: value, blocks: blocks, elements: nil)
//        }
//    }
//    public struct Element: Codable, Hashable, Identifiable {
//        public let id: String
//        public var text: String
//        public var type: ElementType
//        public var value: UserDefinedValue?
//        public var elements: [Element]?
//        
//        public init(_ type: ElementType, text: String = "", value: UserDefinedValue? = nil) {
//            self.id = UUID().uuidString
//            self.text = text
//            self.type = type
//            self.elements = nil
//            self.value = value
//        }
//    }
}


public enum AnyDictionaryValue: Codable, Hashable {
    case string(String)
    case bool(Bool)
    case int(Int)
    case double(Double)
    case strings([String])
    case dictinoary([String : AnyDictionaryValue])
    case dicArray([String : [AnyDictionaryValue]])
    case null
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let v = try? container.decode([String].self) {
            self = .strings(v)
            return
        }
        if let v = try? container.decode(String.self) {
            self = .string(v)
            return
        }
        if let v = try? container.decode(Int.self) {
            self = .int(v)
            return
        }
        if let v = try? container.decode(Double.self) {
            self = .double(v)
            return
        }
        if let v = try? container.decode(Bool.self) {
            self = .bool(v)
            return
        }
        if let v = try? container.decode([String : [AnyDictionaryValue]].self) {
            self = .dicArray(v)
            return
        }
        if let v = try? container.decode([String : AnyDictionaryValue].self) {
            self = .dictinoary(v)
            return
        }
        if container.decodeNil() {
            self = .null
            return
        }
        throw DecodingError.typeMismatch(
            AnyDictionaryValue.self,
            DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "[AnyDictionaryValue] Type is not matched", underlyingError: nil))
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .string(let value):
                try container.encode(value)
            case .strings(let value):
                try container.encode(value)
            case .int(let value):
                try container.encode(value)
            case .double(let value):
                try container.encode(value)
            case .bool(let value):
                try container.encode(value)
            case .dictinoary(let value):
                try container.encode(value)
            case .dicArray(let value):
                try container.encode(value)
            case .null:
                try container.encodeNil()
        }
    }
    
    public func decode<T: Codable>(to: T) throws -> T {
        let data = try JSONEncoder().encode(self)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

public struct ReactionData: Codable, Hashable, Identifiable {
    public let reactionID: String
    public let code: String
    public let createAt, updateAt: Date?
    public let reactionAuthor: MemberData
    
    public init(reactionID: String, code: String, createAt: Date?, updateAt: Date?, reactionAuthor: MemberData) {
        self.reactionID = reactionID
        self.code = code
        self.createAt = createAt
        self.updateAt = updateAt
        self.reactionAuthor = reactionAuthor
    }
    
    enum CodingKeys: String, CodingKey {
        case code, createAt, updateAt
        case reactionID = "reactionId"
        case reactionAuthor
    }
    
    public var id: String {
        self.reactionID
    }
}

