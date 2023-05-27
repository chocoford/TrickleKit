//
//  TrickleEditorParser.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/1/30.
//

import SwiftUI
import WebKit
import Markdown
import TrickleCore

struct BlocksRenderer: View {
    var blocks: [TrickleData.Block]
    var baseFontSize: CGFloat = 16
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(blocks.enumerated()), id: \.1.id) { index, block in
                if let childBlocks: [TrickleData.Block] = block.blocks,
                    !childBlocks.isEmpty {
                    BlocksRenderer(blocks: childBlocks, baseFontSize: baseFontSize)
                        .blockModifier(block,
                                       baseFontSize: baseFontSize)
                } else {
                    let backupNumberedListPrefix: String = {
                        if block.type == .numberedList && block.userDefinedValue == .none {
                            for i in 0..<index {
                                let blockIndex = index - i
                                if case .str(let value) = blocks[blockIndex].userDefinedValue,
                                   let theIndex = Int(value.prefix(value.count - 1)) {
                                    return "\(theIndex + i)."
                                } else if blocks[blockIndex].type != .numberedList {
                                    return "\(i)."
                                }
                            }
                        }
                        return "1."
                    }()
                    
                    TrickleEditorParser.renderElements(block.elements ?? [])
                        .blockModifier(block,
                                       baseFontSize: baseFontSize,
                                       backupNumberedListPrefix: backupNumberedListPrefix)
                }
            }
        }
        
    }
}


public struct TrickleEditorParser {
    @ViewBuilder
    public static func parse<S: RandomAccessCollection,
                                TS: TextSelectability>(_ blocks: S, textSelectable: TS = .enabled,
                                                       baseFontSize: CGFloat = 16) -> some View
    where S.Element == TrickleData.Block, S.Index == Int {
        BlocksRenderer(blocks: Array(blocks), baseFontSize: baseFontSize)
            .textSelection(textSelectable)
    }
    
    @ViewBuilder
    static func renderElements(_ elements: [TrickleData.Element]) -> some View {
        Array(elements.enumerated()).map { (i, element) in
            try! AttributedString(markdown: parseElement(element: element),
                                  options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        }
        .reduce(Text(""), { $0 + Text($1) })
        
    }
    
    
    public static func getContentDescription(_ blocks: [TrickleData.Block], maxLength: Int? = nil) -> String {
        let text = blocks.map { block in
            switch block.type {
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
        }.joined(separator: "\n")
        if let maxLength = maxLength,
           text.count > maxLength {
            return text.prefix(maxLength) + "..."
        } else {
            return text
        }
        
    }
    
    public static func formBlock(string: String) -> [TrickleData.Block] {
        func parseMarkup(_ markup: BlockMarkup, line: Int) -> [TrickleData.Block] {
            var block = TrickleData.Block(type: .richText, blocks: .default)
            var blocks: [TrickleData.Block] = []

            if let heading = markup as? Heading {
                switch heading.level {
                    case 1:
                        block.type = .h1
                    case 2:
                        block.type = .h2
                    case 3:
                        block.type = .h3
                    case 4:
                        block.type = .h4
                    case 5:
                        block.type = .h5
                    case 6:
                        block.type = .h6

                    default:
                        break
                }
            } else if let paragraph = markup as? Paragraph {
                block.type = .richText
            } else if let codeBlock = markup as? CodeBlock {
                block.type = .code
                block.userDefinedValue = .code(.init(language: codeBlock.language ?? ""))
                block.elements = [.init(.text, text: codeBlock.code)]
                return [block]
            } else if let htmlBlock = markup as? HTMLBlock {
                block.type = .code
            } else if let blockQuote = markup as? BlockQuote {
                block.type = .quote
            } else if let blockDirective = markup as? BlockDirective {
                
            } else if let thematicBreak = markup as? ThematicBreak {
                
            } else if let table = markup as? Markdown.Table {
                
            } else if let customBlock = markup as? CustomBlock {

            } else if let orderedList = markup as? OrderedList {
                orderedList.children.forEach {
                    if let blockMarkup = $0 as? BlockMarkup,
                        let range = blockMarkup.range {
                        blocks.append(contentsOf: parseMarkup(blockMarkup, line: range.lowerBound.line))
                    }
                }
                return blocks
            } else if let unorderedList = markup as? UnorderedList {
                unorderedList.children.forEach {
                    if let blockMarkup = $0 as? BlockMarkup,
                        let range = blockMarkup.range {
                        blocks.append(contentsOf: parseMarkup(blockMarkup, line: range.lowerBound.line))
                    }
                }
                return blocks
            } else if let listItem = markup as? ListItem {
//                dump(listItem)
                if let _ = listItem.parent as? UnorderedList {
                    switch listItem.checkbox {
                        case .checked:
                            block.type = .checkbox
                            block.userDefinedValue = .checkbox(.init(status: .checked, operatorID: nil))
                        case .unchecked:
                            block.type = .checkbox
                            block.userDefinedValue = .checkbox(.init(status: .unchecked, operatorID: nil))
                        case .none:
                            block.type = .list
                    }
                } else {
                    block.type = .numberedList
                    block.userDefinedValue = .str("\(listItem.indexInParent+1).")
                }
            }
            
            var chidrenLine = line
            markup.children.forEach {
//                dump($0)
                if let markup = $0 as? BlockMarkup {
                    guard let range = markup.range else { return }
//                    dump(markup)

                    for _ in chidrenLine..<range.lowerBound.line {
                        blocks.append(.newLine)
                    }
                    blocks.append(contentsOf: parseMarkup(markup, line: chidrenLine))
                    chidrenLine = range.upperBound.line + 1
                }
            }
            if !blocks.isEmpty {
                if [.list, .numberedList].contains(block.type) {
                    for i in 0..<blocks.count {
                        blocks[i].type = block.type
                        blocks[i].userDefinedValue = block.userDefinedValue
                    }
                    return blocks
                } else {
                    block.blocks = blocks
                }
            } else {
                block.blocks = nil
            }
            
            block.elements = markup.children.compactMap {
                if let inlineMarkup = $0 as? InlineMarkup {
//                    dump(inlineMarkup)
                    return parseMarkupInlineNode(inlineMarkup)
                } else {
                    return nil
                }
            }
            return [block]
        }
        
        func parseMarkupInlineNode(_ node: InlineMarkup) -> TrickleData.Element {
//            dump(node)
            var element = TrickleData.Element(.text)
            if let emphasis = node as? Emphasis {
                element.type = .italic
                element.elements = emphasis.inlineChildren.map {
                    parseMarkupInlineNode($0)
                }
            } else if let image = node as? Markdown.Image {
                element.type = .image
            } else if let link = node as? Markdown.Link {
                element.type = .link
                element.value = .str(link.destination ?? "")
                element.elements = link.inlineChildren.map {
                    parseMarkupInlineNode($0)
                }
            } else if let striklethrough = node as? Strikethrough {
                element.type = .lineThrough
                element.elements = striklethrough.inlineChildren.map {
                    parseMarkupInlineNode($0)
                }
            } else if let strong = node as? Strong {
                element.type = .bold
                element.elements = strong.inlineChildren.map {
                    parseMarkupInlineNode($0)
                }
            } else if let costomInline = node as? CustomInline {
                
            } else if let inlineCode = node as? InlineCode {
                element.type = .inlineCode
                element.text = inlineCode.code
            } else if let inlineHTML = node as? InlineHTML {
                
            } else if let lineBreak = node as? LineBreak {
                
            } else if let softBreak = node as? SoftBreak {
                element.type = .text
                element.text = "\n"
            } else if let symbolLink = node as? SymbolLink {
                
            } else if let text = node as? Markdown.Text {
                element.type = .text
                element.text = text.string
            }
            
            return element
        }
        
        
        let document = Document(parsing: string, options: [])
        var blocks: [TrickleData.Block] = []
        var line = 1
        document.blockChildren.forEach { markup in
//            dump(markup)
            guard let range = markup.range else { return }
            if line <= range.lowerBound.line - 1 {
                for _ in line..<range.lowerBound.line-1 { // double empty line == newLine
                    blocks.append(TrickleData.Block.newLine)
                }
            }
            blocks.append(contentsOf: parseMarkup(markup, line: range.lowerBound.line))
            if [.list, .numberedList].contains(blocks.last?.type) {
                line = range.upperBound.line
            } else {
                line = range.upperBound.line + 1
            }
        }
        
//        dump(blocks)
        
        return blocks
    }
}

extension TrickleEditorParser {
    static func parseElement(element: TrickleData.Element) -> String {
        switch element.type {
            case .inlineCode:
                return "`\(element.text)`"
                
            case .user:
                return "[@\(element.text) ](https://testapp.trickle.so/workspace/30788161542029315/profile/30799568975167493?m=view)"
            case .bold:
                if let elements = element.elements {
                    return "**\(parseElements(elements))**"
                } else {
                    return ""
                }
            case .italic:
                if let elements = element.elements {
                    return "_\(parseElements(elements))_"
                } else {
                    return ""
                }
            case .url:
                switch element.value {
                    case .str(let urlString):
                        return "[\(element.text)](\(urlString))"
                    case .dic:
                        return "[\(element.text)]()"
                    case .none:
                        return "\(element.text)"
                    default:
                        return ""
                }
            case .link:
                if case .str(let url) = element.value {
                    return "[\(parseElements(element.elements))](\(url))"
                } else {
                    return ""
                }

            case .highlight:
                if let elements = element.elements {
                    return "==\(elements.map{ TrickleEditorParser.parseElement(element: $0) }.joined())=="
                } else {
                    return ""
                }
                
            default:
                return element.text
        }
    }
    
    static func parseElements(_ elements: [TrickleData.Element]?) -> String {
        elements?.map{parseElement(element: $0)}.joined() ?? ""
    }

}


fileprivate extension View {
    @ViewBuilder func blockModifier(_ block: TrickleData.Block,
                                    baseFontSize: CGFloat = 16,
                                    backupNumberedListPrefix: String = "1.") -> some View {
        switch block.type {
            case .h1:
                font(.system(size: baseFontSize * 2, weight: .bold))
            case .h2:
                font(.system(size: baseFontSize * 1.75, weight: .bold))
            case .h3:
                font(.system(size: baseFontSize * 1.5, weight: .semibold))
            case .h4:
                font(.system(size: baseFontSize * 1.375, weight: .semibold))
            case .h5:
                font(.system(size: baseFontSize * 1.25, weight: .medium))
            case .h6:
                font(.system(size: baseFontSize * 1.125, weight: .medium))
                
            case .code:
                CodeBlockView(block: block)
                    
            case .list:
                HStack(alignment: .top) {
                    Circle()
                        .frame(width: 4, height: 4)
                        .foregroundColor(.textColor)
                        .padding(.vertical, baseFontSize / 2)
                    self.font(.system(size: baseFontSize))
                }
            case .numberedList:
                HStack(alignment: .top) {
                    if case .str(let value) = block.userDefinedValue {
                        Text("\(value) ")
                            .padding(.vertical, 2)
                    } else {
                        Text("\(backupNumberedListPrefix) ")
                            .padding(.vertical, 2)
                    }
                    self.font(.system(size: baseFontSize))
                }
                
            case .checkbox:
                let checkboxBlockValue: TrickleData.Block.CheckboxBlockValue = {
                    switch block.userDefinedValue {
                        case .dic(let dic):
                            if let checkboxBlockValue = dic.dictionary.decodeTo(TrickleData.Block.CheckboxBlockValue.self) {
                                return checkboxBlockValue
                            } else {
                                return .init(status: .unchecked, operatorID: nil)
                            }
                        default:
                            return .init(status: .unchecked, operatorID: nil)
                    }
                }()
                    
                HStack(alignment: .top) {
                    Toggle("", isOn: .constant(checkboxBlockValue.status == .checked))
                        .toggleStyle(.checkboxStyle)
                        .fixedSize()
                    self.font(.body)
                }
                
            case .divider:
                DividerBlockView(block: block)
                

            case .gallery:
                GalleryBlockView(block: block, focused: .constant(false))
                
            case .image:
                font(.title3)
                
            case .embed:
                EmbedBlockView(block: block)
                
            case .webBookmark:
                WebBookmarkBlockView(block: block)
                
            case .reference:
                font(.title3)
                
            case .file:
                FileBlockView(block: block)
                
            case .quote:
                QuoteBlockView(block: block)
                
            case .nest:
                font(.body)
                
            case .todos:
                TodosBlockView(block: block)
                
            case .vote:
                VoteBlockView(block: block)
                
            case .richText:
                font(.system(size: baseFontSize))
        }
    }
    
//    @ViewBuilder func elementModifier(_ element: TrickleData.Element) -> some View {
//        switch element.type {
//            case .text:
////                font()
//            case .inlineCode:
//                background(
//                    RoundedRectangle(cornerRadius: 4)
//                        .stroke(.purple)
//                        .foregroundColor(.purple.opacity(2))
//                        .padding(2)
//                )
//            case .user:
//                foregroundColor(.blue)
//            case .bold:
////                fontWeight(.bold)
//            case .url:
//                foregroundColor(.blue)
//            case .image:
//                self
//            case .embed:
//                self
//            case .escape:
//                self
//            case .math:
//                self
//            case .linkToPost:
//                self
//            case .italic:
//                self
//        }
//    }
    
//    static func parseBlockValue<T: Decodable>(_ payload: [String : Any], to: T.Type) -> T? {
//        guard let data = try? JSONSerialization.data(withJSONObject: payload) else { return nil }
//        return try? JSONDecoder().decode(T.self, from: data)
//    }
}



#if DEBUG
struct TrickleEditorParser_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            TrickleEditorParser.parse([
                TrickleData.Block(type: .richText, elements: [
                    TrickleData.Element(.text, text: "123")
                ])
            ])
            .border(.red)
        }
        .frame(width: 500)
//        if let trickles = AppStore.preview.state.workspace.currentGroupTrickles?.value {
//            ScrollView {
////                Text(try! AttributedString(
////                        markdown:"**Thank you!** Please visit our [website](https://example.com)"))
//                ForEach(trickles, id: \.trickleID) { trickle in
//                    VStack(alignment: .leading) {
//                        Text(trickle.userDefinedTitle ?? trickle.title)
//                            .font(.largeTitle)
//                        TrickleEditorParser.parse(trickle.blocks)
//
//                    }
//                    .padding()
//                    .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 8))
//                }
//            }
//            .frame(height: 1800)
//        }
        
    }
}
#endif
