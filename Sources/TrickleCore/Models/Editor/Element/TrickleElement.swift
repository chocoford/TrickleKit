//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/27.
//

import Foundation

extension TrickleData.Element {
    public enum ElementType: String, Codable {
        case text
        case inlineCode = "inline_code"
        case user
        case bold, italic, underline, url, image, embed, escape, math, linkToPost, link, highlight, `subscript`, superscript
        case colored, backgroundColored
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
