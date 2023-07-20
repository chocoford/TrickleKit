//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/27.
//

import SwiftUI
import TrickleCore
import ChocofordEssentials
import TrickleUI

extension NSAttributedString {
    func toBlocks() -> [TrickleBlock] {
        AttributedString(self).toBlocks()
    }
}

extension AttributedString {
    public func toBlocks() -> [TrickleBlock] {
        return self.split("\n").map { line in
            var type: TrickleBlock.BlockType
            
            switch line.runs.first?.attributes.font {
                default:
                    type = .richText
            }
            
            return .text(.init(elements: line.runs.map { run in
                /// `Run` has no instance property to access its string value.
                let description = run.description
                let string = String(description[description.startIndex..<description.index(before: description.lastIndex(of: "{") ?? description.endIndex)])
                
                return .text(.init(text: string))
            }))
        }
    }
}

extension [TrickleBlock] {
    public static func from(_ attributedString: AttributedString) -> Self {
        return attributedString.toBlocks()
    }
}
