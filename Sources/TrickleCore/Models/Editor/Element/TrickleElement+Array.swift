//
//  File.swift
//  
//
//  Created by Chocoford on 2023/7/19.
//

import Foundation

extension [TrickleElement] {
    var text: String { map{$0.text}.joined() }
    var markdownString: String { map{$0.markdownText}.joined() }
    
    public static func text(_ string: String) -> Self {
        [.text(.init(text: string))]
    }
}
