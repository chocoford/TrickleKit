//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/27.
//

import SwiftUI

extension AttributedString {
    func toBlocks(_ config: TrickleEditorConfig = .default) -> [TrickleData.Block] {
        return self.split("\n").map { line in
            var type: TrickleData.Block.BlockType
            
            switch line.runs.first?.attributes.font {
                default:
                    type = .h1
            }
            
            return TrickleData.Block(type: type,
                                     elements: line.runs.map { run in
                /// `Run` has no instance property to access its string value.
                let description = run.description
                let string = String(description[description.startIndex..<description.index(before: description.lastIndex(of: "{") ?? description.endIndex)])
                
                return TrickleData.Element(.text, text: string)
            })
        }
    }
}
