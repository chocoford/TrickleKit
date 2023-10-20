//
//  File.swift
//  
//
//  Created by Chocoford on 2023/7/19.
//

import Foundation
extension TrickleBlock {
    public struct GalleryBlock: TrickleBlockData {
        public var id: String
        public var type: TrickleBlock.BlockType
        public var indent: Int
        public var elements: [TrickleElement.ImageElement]
        
        public init(
            id: String = UUID().uuidString,
            indent: Int = 0,
            elements: [TrickleElement.ImageElement]
        ) {
            self.id = id
            self.type = .gallery
            self.indent = indent
            self.elements = elements//.map{.image($0)}
        }
    }
}
