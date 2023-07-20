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

        init(_ parent: TrickleTextView, stretch: Bool = false) {
            if stretch {
//                let scrollView = TextView.
                self.textView = TextView(frame: .zero, textContainer: parent.store.textContainer)
            } else {
                self.textView = TextView(frame: .zero, textContainer: parent.store.textContainer)
            }
            
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
        
        func updateContentSize() {
            var height: CGFloat = 0
            textView.textLayoutManager?.enumerateTextLayoutFragments(from: textView.textLayoutManager?.documentRange.endLocation,
                                                                     options: [.reverse, .ensuresLayout]) { layoutFragment in
                height = layoutFragment.layoutFragmentFrame.maxY
                return false // stop
            }
            
            parent.height?.wrappedValue = max(height + textView.textContainerInset.top + textView.textContainerInset.bottom, parent.config.minHeight)
        }
    }
}

extension TrickleTextView.Coordinator: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async {
//            print("store.objectWillChange.send()")
            self.parent.store.objectWillChange.send()
            self.updateContentSize()
//            self.parent.blocks = AttributedString(textView.attributedText).toBlocks()
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        
    }
}

extension TrickleTextView.Coordinator: TrickleEditorStoreDelegate {
    public func textContentStorageDidChanged() {
        
    }
}

#endif
