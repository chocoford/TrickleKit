//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/7/19.
//

import Foundation
extension TrickleBlock {
    public struct CodeBlock: TrickleContentBlockData {
        public var id: String
        public var type: TrickleBlock.BlockType
        public var indent: Int
        public var elements: [TrickleElement]
        public var userDefinedValue: CodeBlockValue
        
        public init(id: String = UUID().uuidString,
                    indent: Int = 0,
                    elements: [TrickleElement],
                    userDefinedValue: CodeBlockValue) {
            self.id = id
            self.type = .code
            self.indent = indent
            self.elements = elements
            self.userDefinedValue = userDefinedValue
        }
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<TrickleBlock.CodeBlock.CodingKeys> = try decoder.container(keyedBy: TrickleBlock.CodeBlock.CodingKeys.self)
            self.id = try container.decode(String.self, forKey: TrickleBlock.CodeBlock.CodingKeys.id)
            self.type = try container.decode(TrickleBlock.BlockType.self, forKey: TrickleBlock.CodeBlock.CodingKeys.type)
            self.indent = try container.decode(Int.self, forKey: TrickleBlock.CodeBlock.CodingKeys.indent)
            self.elements = try container.decode([TrickleElement].self, forKey: TrickleBlock.CodeBlock.CodingKeys.elements)
            if let language = try? container.decode(String.self, forKey: TrickleBlock.CodeBlock.CodingKeys.userDefinedValue) {
                self.userDefinedValue = .init(language: language)
            } else {
                self.userDefinedValue = try container.decode(TrickleBlock.CodeBlockValue.self, forKey: TrickleBlock.CodeBlock.CodingKeys.userDefinedValue)
            }
        }
    }
    

    public struct CodeBlockValue: Codable, Hashable {
        public var language: String
        
        public init(language: String) {
            self.language = language
        }
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<TrickleBlock.CodeBlockValue.CodingKeys> = try decoder.container(keyedBy: TrickleBlock.CodeBlockValue.CodingKeys.self)
            self.language = try container.decodeIfPresent(String.self, forKey: TrickleBlock.CodeBlockValue.CodingKeys.language) ?? "plain"
        }
    }
}
