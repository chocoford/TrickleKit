//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/7/19.
//

import Foundation

extension TrickleElement {
    public struct ImageElement: TrickleElementData {
        public var id: String
        public var text: String
        public var type: TrickleElement.ElementType
        public var value: ImageElementValue
        
        public init(
            id: String = UUID().uuidString,
            value: ImageElementValue
        ) {
            self.id = id
            self.text = ""
            self.type = .image
            self.value = value
        }
    }
}
