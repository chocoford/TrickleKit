//
//  TrickleBlockData.swift
//  
//
//  Created by Chocoford on 2023/7/19.
//

import Foundation


// MARK: - Trickle Block
public enum TrickleBlock: Hashable {
    case text(TextBlock)
    case headline(HeadlineBlock)
    case code(CodeBlock)
    case list(ListBlock)
    case checkbox(ChecklistBlock)
    case divider(DividerBlock)
    case gallery(GalleryBlock)
    case image(ImageBlock)
    case embed(EmbedBlock)
    case webBookmark(WebBookmarkBlock)
    case reference(ReferenceBlock)
    case file(FileBlock)
    case nestable(NestableBlock)
    case task(TaskBlock)
    case vote(VoteBlock)
    case progress(ProgressBlock)
    case table(TableBlock)
    
    public enum BlockType: String, Codable {
        case h1, h2, h3, h4, h5, h6, code, list, checkbox
        case richText = "rich_texts"
        case divider = "hr"
        case numberedList = "number_list"
        case gallery, image, embed, webBookmark, reference, file
        case quote, nest
        case todos, vote
        case progress
        case table
    }
}

// MARK: - Codable
extension TrickleBlock: Codable {
    enum CodingKeys: String, CodingKey {
        case type = "type"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let blockType = try container.decode(BlockType.self, forKey: .type)
        
        switch blockType {
            case .richText:
                self = .text(try TextBlock(from: decoder))
            case .h1, .h2, .h3, .h4, .h5, .h6:
                self = .headline(try HeadlineBlock(from: decoder))
            case .code:
                self = .code(try CodeBlock(from: decoder))
            case .list, .numberedList:
                self = .list(try ListBlock(from: decoder))
            case .checkbox:
                self = .checkbox(try ChecklistBlock(from: decoder))
            case .divider:
                self = .divider(try DividerBlock(from: decoder))
            case .gallery:
                self = .gallery(try GalleryBlock(from: decoder))
            case .image:
                self = .image(try ImageBlock(from: decoder))
            case .embed:
                self = .embed(try EmbedBlock(from: decoder))
            case .webBookmark:
                self = .webBookmark(try WebBookmarkBlock(from: decoder))
            case .reference:
                self = .reference(try ReferenceBlock(from: decoder))
            case .file:
                self = .file(try FileBlock(from: decoder))
            case .quote, .nest:
                self = .nestable(try NestableBlock(from: decoder))
            case .todos:
                self = .task(try TaskBlock(from: decoder))
            case .vote:
                self = .vote(try VoteBlock(from: decoder))
            case .progress:
                self = .progress(try ProgressBlock(from: decoder))
            case .table:
                self = .table(try TableBlock(from: decoder))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
            case .text(let block):
                try container.encode(block)
            case .image(let block):
                try container.encode(block)
            case .headline(let block):
                try container.encode(block)
            case .code(let block):
                try container.encode(block)
            case .list(let block):
                try container.encode(block)
            case .checkbox(let block):
                try container.encode(block)
            case .divider(let block):
                try container.encode(block)
            case .gallery(let block):
                try container.encode(block)
            case .embed(let block):
                try container.encode(block)
            case .webBookmark(let block):
                try container.encode(block)
            case .reference(let block):
                try container.encode(block)
            case .file(let block):
                try container.encode(block)
            case .nestable(let block):
                try container.encode(block)
            case .task(let block):
                try container.encode(block)
            case .vote(let block):
                try container.encode(block)
            case .progress(let block):
                try container.encode(block)
            case .table(let block):
                try container.encode(block)
        }
    }
}

// MARK: - Identifiable
extension TrickleBlock: Identifiable {
    public var id: String {
        switch self {
            case .text(let block):
                return block.id
            case .image(let block):
                return block.id
            case .headline(let block):
                return block.id
            case .code(let block):
                return block.id
            case .list(let block):
                return block.id
            case .checkbox(let block):
                return block.id
            case .divider(let block):
                return block.id
            case .gallery(let block):
                return block.id
            case .embed(let block):
                return block.id
            case .webBookmark(let block):
                return block.id
            case .reference(let block):
                return block.id
            case .file(let block):
                return block.id
            case .nestable(let block):
                return block.id
            case .task(let block):
                return block.id
            case .vote(let block):
                return block.id
            case .progress(let block):
                return block.id
            case .table(let block):
                return block.id
        }
    }
}

// MARK: - TrickleBlockData
extension TrickleBlock: TrickleBlockData {
    public var type: BlockType {
        get {
            switch self {
                case .text(let block):
                    return block.type
                case .image(let block):
                    return block.type
                case .headline(let block):
                    return block.type
                case .code(let block):
                    return block.type
                case .list(let block):
                    return block.type
                case .checkbox(let block):
                    return block.type
                case .divider(let block):
                    return block.type
                case .gallery(let block):
                    return block.type
                case .embed(let block):
                    return block.type
                case .webBookmark(let block):
                    return block.type
                case .reference(let block):
                    return block.type
                case .file(let block):
                    return block.type
                case .nestable(let block):
                    return block.type
                case .task(let block):
                    return block.type
                case .vote(let block):
                    return block.type
                case .progress(let block):
                    return block.type
                case .table(let block):
                    return block.type
            }
        }
        set {
            fatalError("Not implement")
        }
    }
    
    public var indent: Int {
        get {
            switch self {
                case .text(let block):
                    return block.indent
                case .image(let block):
                    return block.indent
                case .headline(let block):
                    return block.indent
                case .code(let block):
                    return block.indent
                case .list(let block):
                    return block.indent
                case .checkbox(let block):
                    return block.indent
                case .divider(let block):
                    return block.indent
                case .gallery(let block):
                    return block.indent
                case .embed(let block):
                    return block.indent
                case .webBookmark(let block):
                    return block.indent
                case .reference(let block):
                    return block.indent
                case .file(let block):
                    return block.indent
                case .nestable(let block):
                    return block.indent
                case .task(let block):
                    return block.indent
                case .vote(let block):
                    return block.indent
                case .progress(let block):
                    return block.indent
                case .table(let block):
                    return block.indent
            }
        }
        set {
            fatalError("Not implement")
        }
    }
    
    public var blocks: [TrickleBlock]? {
        switch self {
//            case .text(let block):
//                return block.blocks
//            case .image(let block):
//                return block.blocks
//            case .headline(let block):
//                return block.blocks
//            case .code(let block):
//                return block.blocks
//            case .list(let block):
//                return block.blocks
//            case .checkbox(let block):
//                return block.blocks
//            case .divider(let block):
//                return block.blocks
//            case .gallery(let block):
//                return block.blocks
//            case .embed(let block):
//                return block.blocks
//            case .webBookmark(let block):
//                return block.blocks
//            case .reference(let block):
//                return block.blocks
//            case .file(let block):
//                return block.blocks
            case .nestable(let block):
                return block.blocks
            case .task(let block):
                return block.blocks
            case .vote(let block):
                return block.blocks
            default:
                return nil
        }
    }
    
    public var elements: [TrickleElement]? {
        get {
            switch self {
                case .text(let block):
                    return block.elements
                    //            case .image(let block):
                    //                return block.elements
                case .headline(let block):
                    return block.elements
                case .code(let block):
                    return block.elements
                case .list(let block):
                    return block.elements
                case .checkbox(let block):
                    return block.elements
                default:
                    return nil
                    //            case .divider(let block):
                    //                return block.elements
                    //            case .gallery(let block):
                    //                return block.elements
                    //            case .embed(let block):
                    //                return block.elements
                    //            case .webBookmark(let block):
                    //                return block.elements
                    //            case .reference(let block):
                    //                return block.elements
                    //            case .file(let block):
                    //                return block.elements
                    //            case .nestable(let block):
                    //                return block.elements
                    //            case .task(let block):
                    //                return block.elements
                    //            case .vote(let block):
                    //                return block.elements
            }
        }
        set {
            switch self {
                case .text(var block):
                    block.elements = newValue ?? []
                    self = .text(block)
                case .headline(var block):
                    block.elements = newValue ?? []
                    self = .headline(block)
                case .code(var block):
                    block.elements = newValue ?? []
                    self = .code(block)
                case .list(var block):
                    block.elements = newValue ?? []
                    self = .list(block)
                case .checkbox(var block):
                    block.elements = newValue ?? []
                    self = .checkbox(block)
                default:
                    break
            }
        }
    }
    
    public var text: String {
        switch self {
            case .text(let block):
                return block.text
            case .image(let block):
                return block.text
            case .headline(let block):
                return block.text
            case .code(let block):
                return block.text
            case .list(let block):
                return block.text
            case .checkbox(let block):
                return block.text
            case .divider(let block):
                return block.text
            case .gallery(let block):
                return block.text
            case .embed(let block):
                return block.text
            case .webBookmark(let block):
                return block.text
            case .reference(let block):
                return block.text
            case .file(let block):
                return block.text
            case .nestable(let block):
                return block.text
            case .task(let block):
                return block.text
            case .vote(let block):
                return block.text
            case .progress(let block):
                return block.text
            case .table(let block):
                return block.text
        }
    }
    
    public var markdownString: String {
        switch self {
            case .text(let block):
                return block.markdownString
            case .image(let block):
                return block.markdownString
            case .headline(let block):
                return block.markdownString
            case .code(let block):
                return block.markdownString
            case .list(let block):
                return block.markdownString
            case .checkbox(let block):
                return block.markdownString
            case .divider(let block):
                return block.markdownString
            case .gallery(let block):
                return block.markdownString
            case .embed(let block):
                return block.markdownString
            case .webBookmark(let block):
                return block.markdownString
            case .reference(let block):
                return block.markdownString
            case .file(let block):
                return block.markdownString
            case .nestable(let block):
                return block.markdownString
            case .task(let block):
                return block.markdownString
            case .vote(let block):
                return block.markdownString
            case .progress(let block):
                return block.markdownString
            case .table(let block):
                return block.markdownString
        }
    }
}


// MARK: - getters
extension TrickleBlock {

}

// MARK: - static
extension TrickleBlock {
    public static var `default`: Self {
        .text(.init(elements: [.text(.init(text: ""))]))
    }
    public static var newLine: Self {
        .text(.init(elements: [.text(.init(text: ""))]))
    }
}
