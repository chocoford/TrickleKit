//
//  TrickleContentBlockData.swift
//
//
//  Created by Chocoford on 2023/7/19.
//

import Foundation

/// Trickle Block that contains elements
protocol TrickleContentBlockData: TrickleBlockData {
    var elements: [TrickleElement] { get set }
}

extension TrickleContentBlockData {
    var text: String { elements.text }
    var markdownString: String { elements.markdownString }
//    var blocks: [TrickleBlock]? { nil }
}
