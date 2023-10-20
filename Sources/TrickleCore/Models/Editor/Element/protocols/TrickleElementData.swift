//
//  File.swift
//  
//
//  Created by Chocoford on 2023/7/19.
//

import Foundation
protocol TrickleElementData: Codable, Hashable, Identifiable {
    var id: String { get }
    var text: String { get }
    var type: TrickleElement.ElementType { get set }
    
//    var elements: [TrickleElement]? { get }
    
    var markdownText: String { get }
}

extension TrickleElementData {
    var markdownText: String { text }
//    var elements: [TrickleElement]? { nil }
}


protocol TrickleNestableElementData: TrickleElementData {
    var elements: [TrickleElement] { get set }
}

extension TrickleNestableElementData {
    var text: String { "" }
}
