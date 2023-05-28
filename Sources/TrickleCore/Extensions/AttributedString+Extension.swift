//
//  File.swift
//  
//
//  Created by Chocoford on 2023/3/13.
//

import Foundation

#if os(macOS)
public extension NSAttributedString {
    var range: NSRange {
        .init(location: 0, length: self.length)
    }
}

#endif
