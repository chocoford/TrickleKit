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
            self.textView = TextView(usingTextLayoutManager: true)
            self.parent = parent
            super.init()

            self.textView.delegate = self

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

//        @objc func willSwitchToNSLayoutManager(notification: Notification) {
//            // 处理通知逻辑
//            fatalError("willSwitchToNSLayoutManager")
//        }
//
//        func updateContentSize() {
//            var height: CGFloat = 0
//            textView.textLayoutManager?.enumerateTextLayoutFragments(from: textView.textLayoutManager?.documentRange.endLocation,
//                                                                     options: [.reverse, .ensuresLayout]) { layoutFragment in
//                height = layoutFragment.layoutFragmentFrame.maxY
//                return false // stop
//            }
//
//            parent.height?.wrappedValue = max(height + textView.textContainerInset.height * 2, parent.config.minHeight) // textView.intrinsicContentSize.height
//        }
    }
    
}

extension TrickleTextView.Coordinator: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async {
            self.parent.blocks = AttributedString(textView.attributedText).toBlocks()
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        
    }
}

#endif
