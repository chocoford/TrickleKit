//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/7/19.
//

import Foundation

protocol TrickleBlockData: Codable, Hashable, Identifiable {
    var id: String { get }
    var type: TrickleBlock.BlockType  { get set }
    var indent: Int  { get set }
//    var blocks: [TrickleBlock]? { get }
//    var elements: [TrickleElement]? { get }
    
    var text: String { get }
    var markdownString: String { get }
}

extension TrickleBlockData {
    var text: String { "" }
    var markdownString: String { "" }
//    var blocks: [TrickleBlock]? { nil }
//    var elements: [TrickleElement]? { nil }
}




