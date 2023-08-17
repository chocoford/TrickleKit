//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/27.
//

import Foundation

extension [TrickleBlock] {
    public static var `default`: Self { [.default] }
    
    public func toRawText() -> String {
        var lastNumberedListIndex = 1
        return self.map { block in
            var blockString = String()
            
            blockString = block.markdownString

//            for element in block.elements ?? [] {
//                switch element {
//                    case .text(let textElement):
//                        blockString.append(textElement.text)
//                        
//                    case .image:
//                        break
//                        
//                    default:
//                        blockString.append(element.text)
//                }
//            }
//            
//            
//            
//            switch block.type {
//                case .h1:
//                    blockString = "# " + blockString
//                case .h2:
//                    blockString = "## " + blockString
//                case .h3:
//                    blockString = "### " + blockString
//                case .h4:
//                    blockString = "#### " + blockString
//                case .h5:
//                    blockString = "##### " + blockString
//                case .h6:
//                    blockString = "###### " + blockString
//                    
//                case .list:
//                    blockString = "- " + blockString
//                    
//                case .numberedList:
//                    if case .str(let index) = block.userDefinedValue {
//                        blockString = "\(index) " + blockString
//                        lastNumberedListIndex = Int(index.prefix(index.count - 1)) ?? 1
//                    } else if block.isFirst == false {
//                        blockString = "\(lastNumberedListIndex + 1). " + blockString
//                        lastNumberedListIndex += 1
//                    }
//                    
//                default:
//                    break
//                    
//            }
            return blockString
        }.joined(separator: "\n")
    }
    
    /// Transform `TrickleBlock`s to an `Foundation.AttributedString`
    /// - Parameter baseFontSize: font size of body text. Headline font size will resize according to it.
    /// - Returns:an `AttributedString` that represent the blocks.
    public func toAttributedString(ofBaseSize baseFontSize: CGFloat = 12) -> AttributedString {
        var attributedString = AttributedString()

        for (i, block) in self.enumerated() {
            var blockAttributedString = AttributedString()
            
            // elements
            for element in block.elements ?? [] {
                var elementAttributedString = AttributedString(stringLiteral: element.text)
                switch element.type {
                    case .text:
                        elementAttributedString.font = .systemFont(ofSize: baseFontSize)
                    case .bold:
                        elementAttributedString.font = .boldSystemFont(ofSize: baseFontSize)
                    case .italic:
                        elementAttributedString.inlinePresentationIntent = .emphasized
                    default:
                        elementAttributedString.font = .systemFont(ofSize: baseFontSize)
                }
                
                blockAttributedString.append(elementAttributedString)
            }
            
            switch block.type {
                case .richText:
                    blockAttributedString.presentationIntent = .init(.paragraph, identity: 100)
                case .h1:
                    blockAttributedString.presentationIntent = .init(.header(level: 1), identity: 1)
                case .h2:
                    blockAttributedString.presentationIntent = .init(.header(level: 2), identity: 2)
                case .h3:
                    blockAttributedString.presentationIntent = .init(.header(level: 3), identity: 3)
                case .h4:
                    blockAttributedString.presentationIntent = .init(.header(level: 4), identity: 4)
                case .h5:
                    blockAttributedString.presentationIntent = .init(.header(level: 5), identity: 5)
                case .h6:
                    blockAttributedString.presentationIntent = .init(.header(level: 6), identity: 6)
                    
                case .list:
                    break
//                    blockAttributedString.presentationIntent = .init(.listItem(ordinal: 0), identity: 7)
                    
                case .numberedList:
                    break
//                    if case .str(let index) = block.userDefinedValue {
//                        blockString = "\(index) " + blockString
//                        lastNumberedListIndex = Int(index.prefix(index.count - 1)) ?? 1
//                    } else if block.isFirst == false {
//                        blockString = "\(lastNumberedListIndex + 1). " + blockString
//                        lastNumberedListIndex += 1
//                    }
                    
                default:
                    break
                    
            }
            
            if i < self.count - 1 {
                blockAttributedString.append(AttributedString(stringLiteral: "\n"))
            }
            
            attributedString.append(blockAttributedString)
        }
        
        return attributedString
    }
    
    public static func from(_ text: String) -> Self {
        return text.components(separatedBy: "\n").map {
            TrickleBlock.text(.init(elements: [.text(.init(text: $0))]))
        }
    }
    public static func from(markdown: String) throws -> Self {
        let attributedString = try AttributedString(markdown: markdown)
        return attributedString.toBlocks()
    }
    public static func from(attributedString: AttributedString) -> Self {
        return attributedString.toBlocks()
    }
}

extension NSAttributedString {
    /// Convert `NSAttributedString` to Trickle Block
    public func toBlocks() -> [TrickleBlock] {
        AttributedString(self).toBlocks()
    }
}

extension AttributedString {
    public func toBlocks() -> [TrickleBlock] {
        var results: [TrickleBlock] = []
//        print("[DEBUG] AttributedString - toBlocks:", self.runs)
        for run in self.runs {
            var oldIdentity = -1
            guard let intentType = run.attributes.presentationIntent?.components.first else {
                continue
            }
            var newBlock: TrickleBlock
            if let imageURL = run.attributes.imageURL {
                newBlock = .gallery(.init(elements: [.init(value: .air(.init(url: imageURL.absoluteString, name: "caputre")))]))
            } else if oldIdentity != intentType.identity || results.isEmpty {
                switch intentType.kind {
                    case .paragraph:
                        newBlock = .text(.init(elements: [.text(.init(text: ""))]))
                    case .header(let level):
                        switch level {
                            case 1:
                                newBlock = .headline(.init(type: .h1, text: ""))
                            case 2:
                                newBlock = .headline(.init(type: .h2, text: ""))
                            case 3:
                                newBlock = .headline(.init(type: .h3, text: ""))
                            case 4:
                                newBlock = .headline(.init(type: .h4, text: ""))
                            case 5:
                                newBlock = .headline(.init(type: .h5, text: ""))
                            case 6:
                                newBlock = .headline(.init(type: .h6, text: ""))
                            default:
                                newBlock = .headline(.init(type: .h2, text: ""))
                        }
                    case .orderedList:
                        newBlock = .list(.init(type: .numberedList, indent: 0, elements: []))
                    case .unorderedList:
                        newBlock = .list(.init(type: .list, indent: 0, elements: []))
                    case .listItem(let ordinal):
                        newBlock = .list(.init(type: .list, indent: 0, elements: []))
                    case .codeBlock(let languageHint):
                        newBlock = .code(.init(elements: [], userDefinedValue: .init(language: languageHint ?? "plaintext")))
                    case .blockQuote:
                        newBlock = .nestable(.init(type: .quote, blocks: []))
                    case .thematicBreak:
                        newBlock = .default
                    case .table(let columns):
                        newBlock = .table(.init(userDefinedValue: .init(withHeadings: false, content: [])))
                    case .tableHeaderRow:
                        newBlock = .default
                    case .tableRow(let rowIndex):
                        newBlock = .default
                    case .tableCell(let columnIndex):
                        newBlock = .default
                    @unknown default:
                        newBlock = .default
                }
            } else {
                newBlock = results.popLast()!
            }
            oldIdentity = intentType.identity
            let rawText = run.description[
                String.Index(utf16Offset: 0, in: "")..<run.description.range(of: " {\n")!.lowerBound
            ]
            
            if newBlock.elements == nil { newBlock.elements = [] }
            
            var element: TrickleElement
            switch run.attributes.inlinePresentationIntent {
                default:
                    element = .text(.init(text: String(rawText)))
            }
            
            
            newBlock.elements?.append(element)
            results.append(newBlock)
        }
        
        return results
    }
}
