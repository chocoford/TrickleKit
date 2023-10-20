//
//  File.swift
//  
//
//  Created by Chocoford on 2023/5/27.
//

import Foundation

public enum TrickleElement: Hashable {
    case text(TextElement)
    case image(ImageElement)
    case user(UserElement)
    case nestable(NestableElement)
    case url(URLElement)
    case embed(EmbedElement)
    case colored(ColoredElement)
    case backgroundColored(BackgroundColoredElement)
    case link(LinkElement)
    
    public enum ElementType: String, Codable {
        case text
        case inlineCode = "inline_code"
        case user
        case bold, italic, underline, highlight, `subscript`, superscript // nestable
        case lineThrough = "line_through"
        case url, image, embed, escape, math, linkToPost, link
        case colored, backgroundColored
        case smartText = "smart_text"
    }
}

// MARK: - Codable
extension TrickleElement: Codable {
    enum CodingKeys: String, CodingKey {
        case type = "type"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let elementType = try container.decode(ElementType.self, forKey: .type)
        
        switch elementType {
            case .text:
                self = .text(try TextElement(from: decoder))
            case .inlineCode:
                self = .nestable(try NestableElement(from: decoder))
            case .user:
                self = .user(try UserElement(from: decoder))
            case .bold:
                self = .nestable(try NestableElement(from: decoder))
            case .italic:
                self = .nestable(try NestableElement(from: decoder))
            case .underline:
                self = .nestable(try NestableElement(from: decoder))
            case .highlight:
                self = .nestable(try NestableElement(from: decoder))
            case .subscript:
                self = .nestable(try NestableElement(from: decoder))
            case .superscript:
                self = .nestable(try NestableElement(from: decoder))
            case .lineThrough:
                self = .nestable(try NestableElement(from: decoder))
            case .url:
                self = .url(try URLElement(from: decoder))
            case .image:
                self = .image(try ImageElement(from: decoder))
            case .embed:
                self = .embed(try EmbedElement(from: decoder))
            case .escape:
                self = .text(try TextElement(from: decoder))
            case .math:
                self = .text(try TextElement(from: decoder))
            case .linkToPost:
                self = .text(try TextElement(from: decoder))
            case .link:
                self = .link(try LinkElement(from: decoder))
            case .colored:
                self = .colored(try ColoredElement(from: decoder))
            case .backgroundColored:
                self = .backgroundColored(try BackgroundColoredElement(from: decoder))
            case .smartText:
                self = .text(try TextElement(from: decoder))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
            case .text(let element):
                try container.encode(element)
            case .image(let element):
                try container.encode(element)
            case .user(let element):
                try container.encode(element)
            case .nestable(let element):
                try container.encode(element)
            case .url(let element):
                try container.encode(element)
            case .embed(let element):
                try container.encode(element)
            case .colored(let element):
                try container.encode(element)
            case .backgroundColored(let element):
                try container.encode(element)
            case .link(let element):
                try container.encode(element)
        }
    }
}

// MARK: - Identifiable
extension TrickleElement: Identifiable {
    public var id: String {
        switch self {
            case .text(let element):
                return element.id
            case .image(let element):
                return element.id
            case .user(let element):
                return element.id
            case .nestable(let element):
                return element.id
            case .url(let element):
                return element.id
            case .embed(let element):
                return element.id
            case .colored(let element):
                return element.id
            case .backgroundColored(let element):
                return element.id
            case .link(let element):
                return element.id
        }
    }
}

// MARK: - CustomStringConvertible
extension TrickleElement: CustomStringConvertible {
    public var description: String {
        return self.text
    }
}

// MARK: - TrickleElementData
extension TrickleElement: TrickleElementData {
    public var type: ElementType {
        get {
            switch self {
                case .text(let textElement):
                    return textElement.type
                case .image(let imageElement):
                    return imageElement.type
                case .user(let userElement):
                    return userElement.type
                case .nestable(let nestableElement):
                    return nestableElement.type
                case .url(let uRLElement):
                    return uRLElement.type
                case .embed(let embedElement):
                    return embedElement.type
                case .colored(let coloredElement):
                    return coloredElement.type
                case .backgroundColored(let backgroundColoredElement):
                    return backgroundColoredElement.type
                case .link(let linkElement):
                    return linkElement.type
            }
        }
        set {
            fatalError("not implement")
        }
    }
    
    public var elements: [TrickleElement]? {
        switch self {
            case .nestable(let nestableElement):
                return nestableElement.elements
            case .colored(let coloredElement):
                return coloredElement.elements
            case .backgroundColored(let backgroundColoredElement):
                return backgroundColoredElement.elements
            case .link(let linkElement):
                return linkElement.elements
            default:
                return nil
        }
    }
    
    public var markdownText: String {
        switch self {
            case .text(let element):
                return element.markdownText
            case .user(let element):
                return element.markdownText
            case .url(let element):
                return element.markdownText
            case .colored(let element):
                return element.markdownText
            case .backgroundColored(let element):
                return element.markdownText
            case .nestable(let element):
                return element.markdownText
            case .link(let element):
                return element.markdownText
            case .image(let element):
                return element.markdownText
            case .embed(let element):
                return element.markdownText
        }
    }
    public var text: String {
        switch self {
            case .text(let element):
                return element.text
            case .user(let element):
                return element.text
            case .url(let element):
                return element.text
            case .colored(let element):
                return element.text
            case .backgroundColored(let element):
                return element.text
            case .nestable(let element):
                return element.text
            case .link(let element):
                return element.text
            case .image(let element):
                return element.text
            case .embed(let element):
                return element.text
        }
    }
}
