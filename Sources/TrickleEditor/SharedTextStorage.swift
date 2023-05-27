//
//  File.swift
//  
//
//  Created by Chocoford on 2023/3/14.
//
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import TrickleCore

final class SharedTextStorage: NSTextStorage, ObservableObject {
    private let backingStorage = NSMutableAttributedString()
    
    override var string: String {
        return backingStorage.string
    }
    
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return backingStorage.attributes(at: location, effectiveRange: range)
    }
    
    override func replaceCharacters(in range: NSRange, with str: String) {
        backingStorage.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: str.count - range.length)
    }
    
    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        backingStorage.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
    }
    
    override func processEditing() {
        super.processEditing()
        
        // Perform any additional processing after text storage is edited
        // For example, you can update your model here
    }
}


extension SharedTextStorage: NSTextStorageDelegate {
    
}

final class SharedTextContentStorage: NSTextContentStorage, ObservableObject {
    var blocks: [TrickleData.Block] = .default {
        didSet {
            commonInit()
        }
    }
    
    
    
    var baseFontSize: CGFloat = 16
    
    init(blocks: [TrickleData.Block] = .default, baseFontSize: CGFloat = 16) {
        self.blocks = blocks
        self.baseFontSize = baseFontSize
        super.init()
        
        self.delegate = self
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
        commonInit()
    }
    
    
    private func commonInit() {
        guard let textStorage = self.textStorage else { return }
        textStorage.setAttributedString(.init())
        
        for block in blocks {
            let blockAttributedString = NSMutableAttributedString()
            for (_, element) in (block.elements ?? []).enumerated() {
//                if element.type == .inlineCode {
//                    let attachment = InlineCodeAttachment()
//                    let attrStr = NSMutableAttributedString(string: element.text)
//                    attrStr.addAttribute(., value: <#T##Any#>, range: <#T##NSRange#>)
//                    attachment.contents = try? attrStr.data(from: .init(location: 0, length: attrStr.length))
//                    let elementAttributedString = NSMutableAttributedString(attachment: attachment)
//                    elementAttributedString.append(.init(string: element.text))
//                    blockAttributedString.append(elementAttributedString)
//                } else {
                let elementAttributedString = NSMutableAttributedString(string: element.text)
                elementAttributedString.addAttribute(.elementType, value: element.type.rawValue, range: .init(location: 0, length: elementAttributedString.length))
                blockAttributedString.append(elementAttributedString)
//                }
//                let attributedString = try? AttributedString(markdown: TrickleEditorParser.parseElement(element: element))
//                blockAttributedString.append(NSAttributedString(attributedString ?? ""))
            }
            
            let linebreak = NSMutableAttributedString(string: "\n")
            linebreak.addAttribute(.elementType, value: TrickleData.Element.ElementType.text.rawValue, range: .init(location: 0, length: linebreak.length))
            blockAttributedString.append(linebreak)
            blockAttributedString.addAttribute(.blockType, value: block.type.rawValue, range: .init(location: 0, length: blockAttributedString.length))
#if os(macOS)
            blockAttributedString.addAttribute(.foregroundColor, value: NSColor.textColor, range: .init(location: 0, length: blockAttributedString.length))
#elseif os(iOS)
            blockAttributedString.addAttribute(.foregroundColor, value: UIColor.lightText, range: .init(location: 0, length: blockAttributedString.length))
#endif
            textStorage.append(blockAttributedString)
        }
    }
}

extension SharedTextContentStorage: NSTextContentStorageDelegate {
    func textContentManager(_ textContentManager: NSTextContentManager, textElementAt location: NSTextLocation) -> NSTextElement? {
        return nil
    }
    
    func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
        #if os(macOS)
        typealias Font = NSFont
        #elseif os(iOS)
        typealias Font = UIFont
        #endif
        
        var paragraphWithDisplayAttributes: NSTextParagraph? = nil
        let originalText = textContentStorage.textStorage!.attributedSubstring(from: range)
        
        if let blockType = originalText.attribute(.blockType, at: 0, effectiveRange: nil) as? String {
            var displayAttributes: [NSAttributedString.Key: AnyObject] = [:]
            let textWithDisplayAttributes = NSMutableAttributedString()
            
            switch blockType {
                case TrickleData.Block.BlockType.h1.rawValue:
                    displayAttributes[.font] = Font.systemFont(ofSize: baseFontSize * 2, weight: .bold)
                    break
                case TrickleData.Block.BlockType.h2.rawValue:
                    displayAttributes[.font] = Font.systemFont(ofSize: baseFontSize * 1.75, weight: .bold)
                    break
                case TrickleData.Block.BlockType.h3.rawValue:
                    displayAttributes[.font] = Font.systemFont(ofSize: baseFontSize * 1.5, weight: .semibold)
                    break
                case TrickleData.Block.BlockType.h4.rawValue:
                    displayAttributes[.font] = Font.systemFont(ofSize: baseFontSize * 1.375, weight: .semibold)
                    break
                case TrickleData.Block.BlockType.h5.rawValue:
                    displayAttributes[.font] = Font.systemFont(ofSize: baseFontSize * 1.25, weight: .medium)
                    break
                case TrickleData.Block.BlockType.h6.rawValue:
                    displayAttributes[.font] = Font.systemFont(ofSize: baseFontSize * 1.125, weight: .medium)
                    break

                default:
                    displayAttributes[.font] = Font.systemFont(ofSize: baseFontSize, weight: .regular)
                    break
            }
            
            
            originalText.enumerateAttribute(.elementType,
                                            in: .init(location: 0, length: originalText.length)) { val, range, _ in
//                print(originalText, range, originalText.length)
                let attrString = originalText.attributedSubstring(from: range)
                var elementAttrString = NSMutableAttributedString(attributedString: attrString)
                
                guard let elementType = val as? TrickleData.Element.ElementType.RawValue else { return }
                switch elementType {
                    case TrickleData.Element.ElementType.inlineCode.rawValue:
                        #if os(macOS)
                        elementAttrString.addAttributes(displayAttributes, range: elementAttrString.range)
                        let attachment = InlineCodeAttachment(data: try? elementAttrString.data(from: elementAttrString.range), ofType: nil)
                        elementAttrString = NSMutableAttributedString(attachment: attachment)
                        #endif
                        break
//                        elementAttrString =
//                        elementAttrString = (try? NSMutableAttributedString(markdown: "`\(attrString.string)`")) ?? .init(string: "")
//                        elementAttrString.addAttribute(.foregroundColor, value: NSColor(red: 239/255.0, green: 68/255.0, blue: 68/255.0, alpha: 1.0),
//                                                       range: .init(location: 0, length: elementAttrString.length))
//                        elementAttrString.addAttribute(.backgroundColor, value: NSColor(red: 239/255.0, green: 68/255.0, blue: 68/255.0, alpha: 0.2),
//                                                       range: .init(location: 0, length: elementAttrString.length))
                        
                    default:
                        break
                }
                
                textWithDisplayAttributes.append(elementAttrString)
            }
            
//            textLayoutManagers.first?.usageBoundsForTextContainer.width
            

//            print(textWithDisplayAttributes)
            textWithDisplayAttributes.addAttributes(displayAttributes, range: .init(location: 0, length: textWithDisplayAttributes.length))
            paragraphWithDisplayAttributes = NSTextParagraph(attributedString: textWithDisplayAttributes)
        }
        return paragraphWithDisplayAttributes
    }


    
//    func textContentManager(_ textContentManager: NSTextContentManager,
//                            shouldEnumerate textElement: NSTextElement,
//                            options: NSTextContentManager.EnumerationOptions = []) -> Bool {
//        if let paragraph = textElement as? NSTextParagraph {
//            let elementType = paragraph.attributedString.attribute(.elementType, at: 0, effectiveRange: nil)
////            print(paragraph.attributedString.string, elementType)
//            if elementType == nil {
//                return false
//            }
//        } else {
//            print("not a paragraph")
//        }
//        return true
//    }
}


final class SharedTextContentManager: NSTextContentManager {
    
}



// MARK: - NSAttributedString.Key

extension NSAttributedString.Key {
    public static var blockType: NSAttributedString.Key {
        return NSAttributedString.Key("TrickleBlockType")
    }
    
    public static var elementType: NSAttributedString.Key {
        return NSAttributedString.Key("TrickleElementType")
    }
    
    public static var gallery: NSAttributedString.Key {
        return NSAttributedString.Key("TrickleGallery")
    }
}



extension AttributeScopes {
    struct TrickleAttributes: AttributeScope {
//        let message: MessageAttribute
        let blockType: TrickleBlockType
        let elementType: TrickleElementType
        
        
        let swiftUI: SwiftUIAttributes
    }
    
    
    
    var trickle: TrickleAttributes.Type { TrickleAttributes.self }
}


extension AttributeScopes.TrickleAttributes {
    struct TrickleBlockType: CodableAttributedStringKey, MarkdownDecodableAttributedStringKey {
        typealias Value = TrickleData.Block.BlockType
        
        static var name: String {
            "TrickleBlockType"
        }
    }

    struct TrickleElementType: CodableAttributedStringKey, MarkdownDecodableAttributedStringKey {
        typealias Value = TrickleData.Element.ElementType
        
        static var name: String {
            "TrickleElementType"
        }
    }

}
