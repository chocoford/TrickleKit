//
//  File.swift
//  
//
//  Created by Chocoford on 2023/3/13.
//

import Foundation
import SwiftUI

#if os(macOS)
extension NSAttributedString {
    func toBlocks() -> [TrickleData.Block] {
        AttributedString(self).toBlocks()
    }
    
    var range: NSRange {
        .init(location: 0, length: self.length)
    }
}

#endif

extension AttributedString {
    func split(_ seperator: Character) -> [AttributedString] {
        var components: [AttributedString] = []
        
        var attributedString = self
        
        var string = self.unicodeScalars.map { scalar in
            scalar.description
        }.joined()
        while true {
            let lastIndex: AttributedString.Index = .init(string.startIndex, within: attributedString)!
            guard let stringIndex = string.firstIndex(of: seperator),
                  let index = AttributedString.Index(stringIndex, within: attributedString)
            else {
                components.append(attributedString)
                break
            }
            
            let subString = attributedString[lastIndex..<index]
            components.append(AttributedString(subString))
            
            if index == attributedString.endIndex { break }
            
            attributedString = AttributedString(attributedString[attributedString.index(afterCharacter: index)..<attributedString.endIndex])
            string = String(string[string.index(after: stringIndex)..<string.endIndex])
        }
        
        return components
    }
    
    func toBlocks(_ config: TrickleEditorConfig = .default) -> [TrickleData.Block] {
        return self.split("\n").map { line in
            var type: TrickleData.Block.BlockType
            
            switch line.runs.first?.attributes.font {
//                case .some(.system(size: config.baseFontSize * 2)):
//                    type = .h1
//
                default:
                    type = .h1
            }
            
            
//            line.runs.first?.attributes.font == .system(size: <#T##CGFloat#>)
            
            return TrickleData.Block(type: type,
                                     elements: line.runs.map { run in
                /// `Run` has no instance property to access its string value.
                let description = run.description
                let string = String(description[description.startIndex..<description.index(before: description.lastIndex(of: "{") ?? description.endIndex)])
                
//                run.attributes
                
                return TrickleData.Element(.text, text: string)
            })
        }
    }
}
 
