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
    public var allowGuestMemberComment, allowGuestMemberReact, allowWorkspaceMemberComment, allowWorkspaceMemberReact: Bool
    public var authorMemberInfo: MemberData
    public var authorAppMemberInfo: MemberData?
    public var blocks: [Block]
    public var commentCounts: Int
    public var editBy: MemberData?
    public var hasStarred, isPinned, isPublic: Bool
    public var lastViewInfo: LastViewData
    public var mentionedMemberInfo: [MentionedMemberData]
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
    
    enum CodingKeys: String, CodingKey {
        case trickleID = "trickleId"
        case allowGuestMemberComment, allowGuestMemberReact, allowWorkspaceMemberComment, allowWorkspaceMemberReact, authorAppMemberInfo, authorMemberInfo, blocks, commentCounts, createAt, editAt, editBy, hasStarred, isPinned, isPublic, lastViewInfo, mentionedMemberInfo, reactionInfo, groupInfo, referInfo, title
        case threadID = "threadId"
        case updateAt, userDefinedTitle, viewedMemberInfo, editingMemberInfo, fieldData
    }
}

extension TrickleData: Identifiable {
    public var id: String {
        trickleID
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
            return TrickleEditorParser.getContentDescription(blocks, maxLength: 20)
        }
    }
}

extension TrickleData {
    public struct ReferData: Codable, Hashable {}
    public struct ViewedMemberData: Codable, Hashable {
        public let counts: Int
        public let members: [MemberData]
    }
    public struct LastViewData: Codable, Hashable {
        public let unreadCount: Int?
        public let lastViewedAt: Int?
        public let lastACKMessageID: String?
        public let lastACKMessageCreateAt: Int?

        enum CodingKeys: String, CodingKey {
            case unreadCount, lastViewedAt
            case lastACKMessageID = "lastAckMessageId"
            case lastACKMessageCreateAt = "lastAckMessageCreateAt"
        }
    }
    public struct GroupData: Codable, Hashable {
        public let groupID, ranks: String
        
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
    public struct Block: Codable, Hashable, Identifiable {
        public let id: String
        public var type: BlockType
        public var isFirst: Bool
        public var indent: Int
        public var blocks: [Block]?
        public var elements: [Element]?
        public var isCurrent: Bool
        public var constraint: String?
        public var display: String
        public var userDefinedValue: UserDefinedValue?
        
        private init(type: BlockType, value: UserDefinedValue? = nil, blocks: [Block]?, elements: [Element]?) {
            self.id = UUID().uuidString
            self.type = type
            self.isFirst = true
            self.indent = 0
            self.blocks = blocks
            self.elements = elements
            self.isCurrent = false
            self.constraint = "free"
            self.display = "block"
            self.userDefinedValue = value
        }
        
        public init(type: BlockType, value: UserDefinedValue? = nil, elements: [Element]) {
            self.init(type: type, value: value, blocks: nil, elements: elements)
        }
        
        public init(type: BlockType, value: UserDefinedValue? = nil, blocks: [Block]) {
            self.init(type: type, value: value, blocks: blocks, elements: nil)
        }
        
        
    }
    public struct Element: Codable, Hashable, Identifiable {
        public let id: String
        public var text: String
        public var type: ElementType
        public var value: UserDefinedValue?
        public var elements: [Element]?
        public var isCurrent: Bool
        
        public init(_ type: ElementType, text: String = "", value: UserDefinedValue? = nil) {
            self.id = UUID().uuidString
            self.text = text
            self.type = type
            self.elements = nil
            self.isCurrent = false
            self.value = value
        }
    }
}


extension TrickleData.Block {
    public static var `default`: Self {
        .init(type: .richText, elements: [.init(.text, text: "")])
    }
    public static var newLine: Self {
        .init(type: .richText, elements: [.init(.text, text: "")])
    }
    
    public enum BlockType: String, Codable {
        case h1, h2, h3, h4, h5, h6, code, list, checkbox
        case richText = "rich_texts"
        case divider = "hr"
        case numberedList = "number_list"
        case gallery, image, embed, webBookmark, reference, file
        case quote, nest
        case todos, vote
    }
    
    public enum UserDefinedValue: Codable, Hashable {
        case str(String)
        case dic([String: AnyDictionaryValue])
        
        case checkbox(CheckboxBlockValue)
        case file(FileBlockValue)
        case webBookmark(WebBookmarkBlockValue)
        case embed(EmbedBlockValue)
        case code(CodeBlockValue)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            if let v = try? container.decode(CheckboxBlockValue.self) {
                self = .checkbox(v)
                return
            }
            if let v = try? container.decode(FileBlockValue.self) {
                self = .file(v)
                return
            }
            if let v = try? container.decode(WebBookmarkBlockValue.self) {
                self = .webBookmark(v)
                return
            }
            if let v = try? container.decode(EmbedBlockValue.self) {
                self = .embed(v)
                return
            }
            if let v = try? container.decode(CodeBlockValue.self) {
                self = .code(v)
                return
            }
            
            if let v = try? container.decode(String.self) {
                self = .str(v)
                return
            }
            if let v = try? container.decode([String: AnyDictionaryValue].self) {
                self = .dic(v)
                return
            }
            throw DecodingError.typeMismatch(
                UserDefinedValue.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "[Block UserDefinedValue] Type is not matched", underlyingError: nil))
        }
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
                case .checkbox(let value):
                    try container.encode(value)
                case .file(let value):
                    try container.encode(value)
                case .webBookmark(let value):
                    try container.encode(value)
                case .embed(let value):
                    try container.encode(value)
                case .code(let value):
                    try container.encode(value)
                case .str(let value):
                    try container.encode(value)
                case .dic(let value):
                    try container.encode(value)
            }
        }
    }
}

extension TrickleData.Element {
    public enum ElementType: String, Codable {
        case text
        case inlineCode = "inline_code"
        case user
        case bold, italic, url, image, embed, escape, math, linkToPost, link, highlight, `subscript`, superscript
        case lineThrough = "line_through"
        case smartText = "smart_text"
    }
    public enum UserDefinedValue: Codable, Hashable {
        case str(String)
        case dic([String: AnyDictionaryValue])
        
        case galleryImageValue(ImageElementValue)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            if let v = try? container.decode(ImageElementValue.self) {
                self = .galleryImageValue(v)
                return
            }
            
            if let v = try? container.decode(String.self) {
                self = .str(v)
                return
            }
            
            if let v = try? container.decode([String : AnyDictionaryValue].self) {
                self = .dic(v)
                return
            }
            throw DecodingError.typeMismatch(
                UserDefinedValue.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "[Element UserDefinedValue] Type is not matched", underlyingError: nil))
        }
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
                case .galleryImageValue(let value):
                    try container.encode(value)
                    
                case .str(let value):
                    try container.encode(value)
                case .dic(let value):
                    try container.encode(value)
                    
            }
        }
    }
}

extension Array<TrickleData.Block> {
    public static var `default`: Self {
        [.default]
    }
    
    public func toAttributedString(baseFontSize: CGFloat = 16) -> AttributedString {
        var attributedString = AttributedString()
        var lastNumberedListIndex = 1
        for block in self {
            var blockString = AttributedString()
            
            for element in block.elements ?? [] {
                switch element.type {
                    case .text:
                        blockString.append(AttributedString(stringLiteral: element.text))
                        
                    case .image:
//                        AttributedString().attachment = .init(data: <#T##Data?#>, ofType: <#T##String?#>)
//                        blockString.append()
                        break
                        
                    default:
                        blockString.append(AttributedString(stringLiteral: element.text))
                }
            }
            
            blockString.font = .systemFont(ofSize: baseFontSize, weight: .regular)
            switch block.type {
                case .h1:
                    blockString.font = .systemFont(ofSize: baseFontSize * 2, weight: .bold)
                case .h2:
                    blockString.font = .systemFont(ofSize: baseFontSize * 1.75, weight: .bold)
                case .h3:
                    blockString.font = .systemFont(ofSize: baseFontSize * 1.5, weight: .semibold)
                case .h4:
                    blockString.font = .systemFont(ofSize: baseFontSize * 1.375, weight: .semibold)
                case .h5:
                    blockString.font = .systemFont(ofSize: baseFontSize * 1.25, weight: .medium)
                case .h6:
                    blockString.font = .systemFont(ofSize: baseFontSize * 1.125, weight: .medium)
                    
                    
                    
                case .list:
                    blockString = AttributedString(stringLiteral: "•  ") + blockString
//                    blockString.paragraphStyle.
                    
                case .numberedList:
                    if case .str(let index) = block.userDefinedValue {
                        blockString = AttributedString(stringLiteral: "\(index) ") + blockString
                        lastNumberedListIndex = Int(index.prefix(index.count - 1)) ?? 1
                    } else if block.isFirst == false {
                        blockString = AttributedString(stringLiteral: "\(lastNumberedListIndex + 1). ") + blockString
                        lastNumberedListIndex += 1
                    }
                    
                default:
                    blockString.font = .systemFont(ofSize: baseFontSize, weight: .regular)

            }
            
            blockString.append(AttributedString(stringLiteral: "\n"))
            attributedString.append(blockString)
            
            
        }
        
        return attributedString
    }
    
    public func toRawText() -> String {
        var lastNumberedListIndex = 1
        return self.map { block in
            var blockString = String()
            
            for element in block.elements ?? [] {
                switch element.type {
                    case .text:
                        blockString.append(element.text)
                        
                    case .image:
                        break
                        
                    default:
                        blockString.append(element.text)
                }
            }
            
            switch block.type {
                case .h1:
                    blockString = "# " + blockString
                case .h2:
                    blockString = "## " + blockString
                case .h3:
                    blockString = "### " + blockString
                case .h4:
                    blockString = "#### " + blockString
                case .h5:
                    blockString = "##### " + blockString
                case .h6:
                    blockString = "###### " + blockString
                    
                case .list:
                    blockString = "- " + blockString
                    
                case .numberedList:
                    if case .str(let index) = block.userDefinedValue {
                        blockString = "\(index) " + blockString
                        lastNumberedListIndex = Int(index.prefix(index.count - 1)) ?? 1
                    } else if block.isFirst == false {
                        blockString = "\(lastNumberedListIndex + 1). " + blockString
                        lastNumberedListIndex += 1
                    }
                    
                default:
                    break
                    
            }
            return blockString
        }.joined(separator: "\n")
    }
    
}

public enum AnyDictionaryValue: Codable, Hashable {
    case string(String)
    case bool(Bool)
    case int(Int)
    case double(Double)
    case strings([String])
    case dictinoary([String : AnyDictionaryValue])
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
            case .null:
                try container.encodeNil()
        }
    }
    
    public func decode<T: Codable>(to: T) throws -> T {
        let data = try JSONEncoder().encode(self)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

public struct ReactionData: Codable, Hashable {
    public let code: String
    public let createAt, updateAt: Date?
    public let reactionID: String
    public let reactionAuthor: MemberData
    
    enum CodingKeys: String, CodingKey {
        case code, createAt, updateAt
        case reactionID = "reactionId"
        case reactionAuthor
    }
}

