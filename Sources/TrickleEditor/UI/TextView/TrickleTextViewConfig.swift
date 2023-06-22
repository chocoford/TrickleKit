//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/6/5.
//

import Foundation

enum KeyboardEvent {
    case arrowUp // (NSEvent)
    case arrowDown // (NSEvent)
    case enter // (NSEvent)
    case deleteLine
}

extension TrickleTextView {
    class Config: ObservableObject {
        var editable: Bool = true
        var minHeight: CGFloat = 14
        
        init() {}
    }
}

extension TrickleTextView {
    func minHeight(_ minHeight: CGFloat) -> TrickleTextView {
        self.config.minHeight = minHeight
        return self
    }
    
    func editable(_ flag: Bool = true) -> TrickleTextView {
        self.config.editable = flag
        return self
    }
}
