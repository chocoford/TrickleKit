//
//  File.swift
//  
//
//  Created by Chocoford on 2023/7/19.
//

import Foundation

extension TrickleElement {
    public struct TextElement: TrickleElementData {
        public var id: String = UUID().uuidString
        public var text: String
        public var type: TrickleElement.ElementType = .text
        
        public init(
            id: String = UUID().uuidString,
            text: String
        ) {
            self.id = id
            self.text = text
            self.type = .text
        }
    }
}
