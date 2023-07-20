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
}
