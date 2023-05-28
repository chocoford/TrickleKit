//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/28.
//

import Foundation
import SwiftUI
import TrickleCore

public extension AttributedString {
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
}
 
