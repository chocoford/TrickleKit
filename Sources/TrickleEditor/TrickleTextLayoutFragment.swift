//
//  TrickleTextFragment.swift
//  
//
//  Created by Chocoford on 2023/3/14.
//

import SwiftUI

class TrickleTextLayoutFragment: NSTextLayoutFragment {
    var showActions: Bool = true
    
    override var leadingPadding: CGFloat { return showActions ? 40.0 : 0 }
}
