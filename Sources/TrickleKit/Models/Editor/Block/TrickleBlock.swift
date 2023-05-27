//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/27.
//

import Foundation
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
