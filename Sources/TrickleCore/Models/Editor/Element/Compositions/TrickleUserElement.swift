//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/7/19.
//

import Foundation

extension TrickleElement {
    public struct UserElement: TrickleElementData {
        public var id: String
        public var text: String
        public var type: TrickleElement.ElementType
        public var value: String?
        
        public init(id: String = UUID().uuidString,
                    text: String,
                    value: String? = nil) {
            self.id = id
            self.text = text
            self.type = .user
            self.value = value
        }
    }
}
