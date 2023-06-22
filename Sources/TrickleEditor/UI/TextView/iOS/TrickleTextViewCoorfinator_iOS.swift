//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/6/16.
//

#if os(iOS)
import Foundation
import SwiftUI
import UIKit

extension TrickleTextView {
    public class Coordinator: NSObject {
        typealias TextView = UITextView
        let textView: TextView

        var parent: TrickleTextView

        init(_ parent: TrickleTextView) {
            self.textView = TextView(frame: .zero, textContainer: parent.store.textContainer)
            self.parent = parent
            super.init()

            self.textView.delegate = self
            self.parent.store.delegate = self

//            self.textView.didFocused = {
//                self.parent.isFocus?.wrappedValue = true
//                self.parent.focusState = true
//            }
            
//            NotificationCenter.default.addObserver(self,
//                                                   selector: #selector(willSwitchToNSLayoutManager),
//                                                   name: TextView.willSwitchToNSLayoutManagerNotification,
//                                                   object: nil)
//
        }
    }
    
}

extension TrickleTextView.Coordinator: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
//        DispatchQueue.main.async {
//            self.parent.blocks = AttributedString(textView.attributedText).toBlocks()
//        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        
    }
}

extension TrickleTextView.Coordinator: TrickleEditorStoreDelegate {
    public func textContentStorageDidChanged() {
        
    }
}

#endif
