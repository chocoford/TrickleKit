//
//  TrickleNestableBlockData.swift
//  
//
//  Created by Dove Zachary on 2023/7/19.
//

import Foundation

/// Trickle Block that contains blocks
protocol TrickleNestableBlockData: TrickleBlockData {
    var blocks: [TrickleBlock] { get set }
}

extension TrickleNestableBlockData {
    var text: String { blocks.map{$0.text}.joined() }
    var markdownString: String { blocks.map{$0.markdownString}.joined() }
//    var elements: [TrickleElement]? { nil }
}
