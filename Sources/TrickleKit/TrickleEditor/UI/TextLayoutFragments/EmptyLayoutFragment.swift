//
//  File.swift
//  
//
//  Created by Chocoford on 2023/3/16.
//

import Foundation

#if os(macOS)
import AppKit

class EmptyLayoutFragment: NSTextLayoutFragment {
    override func draw(at point: CGPoint, in context: CGContext) {
        
    }
}
#endif
