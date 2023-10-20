//
//  File.swift
//  
//
//  Created by Chocoford on 2023/7/19.
//

import Foundation

extension TrickleElement {
    public struct NestableElement: TrickleElementData {
        public var id: String
        public var text: String { elements.map{$0.text}.joined() }
        public var type: TrickleElement.ElementType
        public var elements: [TrickleElement]
    }
    
    public struct ColoredElement: TrickleElementData {
        public var id: String
        public var text: String { elements.map{$0.text}.joined() }
        public var type: TrickleElement.ElementType
        public var value: ColoredElementValue
        public var elements: [TrickleElement]
    }
    
    public struct BackgroundColoredElement: TrickleElementData {
        public var id: String
        public var text: String { elements.map{$0.text}.joined() }
        public var type: TrickleElement.ElementType
        public var value: BackgroundColoredElementValue
        public var elements: [TrickleElement]
    }
}
