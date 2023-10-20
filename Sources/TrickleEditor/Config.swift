//
//  File.swift
//  
//
//  Created by Chocoford on 2023/7/17.
//

import SwiftUI
import TrickleCore


public class TrickleEditorConfig: ObservableObject {
    public static var `default` = TrickleEditorConfig(version: .v0,
                                                      selectable: true,
                                                      editable: true,
                                                      scrollable: true,
                                                      isSending: false,
                                                      singleLine: false,
                                                      showToolbar: false,
                                                      rounded: false,
                                                      showRowActions: true,
                                                      baseFontSize: 16)
    
    public enum Version {
        case v0
        case v1
        case v2
    }
    
    var version: Version = .v0
    
    var editable: Bool = true
    var selectable: Bool = true
    var scrollable: Bool = true
    var isSending: Bool = false
    var singleLine: Bool = false
    var showToolbar: Bool = true
    var rounded: Bool = true
    var showRowActions: Bool = true
    
    
    var baseFontSize: CGFloat = 16
    var maxHeight: CGFloat?
    
    var onSend: (([TrickleBlock]) -> Void)?
        
    public init(version: Version,
                selectable: Bool,
                editable: Bool, scrollable: Bool,
                isSending: Bool, singleLine: Bool,
                showToolbar: Bool, rounded: Bool,
                showRowActions: Bool,
                baseFontSize: CGFloat,
                maxHeight: CGFloat? = nil) {
        self.version = version
        
        self.editable = editable
        self.scrollable = scrollable
        self.isSending = isSending
        self.singleLine = singleLine
        self.showToolbar = showToolbar
        self.rounded = rounded
        self.showRowActions = showRowActions
        self.baseFontSize = baseFontSize
        self.maxHeight = maxHeight
    }
}
