//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/7/19.
//

import Foundation

extension TrickleElement {
    public struct BoldElement: TrickleElementData {
        public var id: String
        public var text: String
        public var type: TrickleElement.ElementType
        public var elements: [TrickleElement]
    }
}