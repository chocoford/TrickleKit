//
//  File.swift
//  
//
//  Created by Chocoford on 2023/7/19.
//

import Foundation

extension TrickleElement {
    public struct LinkElement: TrickleElementData {
        public var id: String
        public var text: String
        public var type: TrickleElement.ElementType
        public var value: String
        public var elements: [TrickleElement]
    }
}
