//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/6/5.
//
#if os(macOS)
import Foundation
import AppKit
import SwiftUI

// MARK: - Coordinator
extension TrickleTextView {
    public class Coordinator: NSObject {
        typealias TextView = TTextView
        
        let editorView: NSScrollView
        let textView: TextView

        var parent: TrickleTextView

//        var selectedFrame: NSRect? = nil
//
//        lazy var toolbarView: NSView = {
//            let view = NSHostingView(rootView: ToolbarView())
//            view.setFrameSize(.init(width: 100, height: 40))
//            view.isHidden = true
//            return view
//        }()
//
        init(_ parent: TrickleTextView) {
            self.editorView = TextView.scrollableTextView()
            self.textView = TextView() //editorView.documentView as! TextView
//            self.textView.sharedTextStorage = parent.textStorage
            self.parent = parent
            super.init()
//            editorView.drawsBackground = false
//            textView.drawsBackground = false

            self.textView.delegate = self
//            textView.textLayoutManager?.delegate = self
//            assert(textView.textLayoutManager != nil, "textLayoutManager is nil")

            self.textView.didFocused = {
                self.parent.isFocus?.wrappedValue = true
                self.parent.focusState = true
            }
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(willSwitchToNSLayoutManager),
                                                   name: TTextView.willSwitchToNSLayoutManagerNotification,
                                                   object: nil)
            
        }

        @objc func willSwitchToNSLayoutManager(notification: Notification) {
            // 处理通知逻辑
            fatalError("willSwitchToNSLayoutManager")
        }
//
        func updateContentSize() {
            var height: CGFloat = 0
            textView.textLayoutManager?.enumerateTextLayoutFragments(from: textView.textLayoutManager?.documentRange.endLocation,
                                                                     options: [.reverse, .ensuresLayout]) { layoutFragment in
                height = layoutFragment.layoutFragmentFrame.maxY
                return false // stop
            }
            
            parent.height?.wrappedValue = max(height + textView.textContainerInset.height * 2, parent.config.minHeight) // textView.intrinsicContentSize.height
        }
    }
}
//
extension TrickleTextView.Coordinator: NSTextViewDelegate {
    public func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? TextView else {
            return
        }
        DispatchQueue.main.async {
            self.parent.blocks = textView.attributedString().toBlocks()
            self.updateContentSize()
        }
    }
    
    public func textDidEndEditing(_ notification: Notification) {
        guard let textView = notification.object as? TextView else {
            return
        }
        self.parent.isFocus?.wrappedValue = false
        self.parent.focusState = false
//        print("didEndEditing", textView)
    }
//
//    public func textViewDidChangeSelection(_ notification: Notification) {
//        guard let textView = notification.object as? NSTextView,
//              let textLayoutManager = textView.textLayoutManager,
//              let selection = textLayoutManager.textSelections.first,
//              let textRange = selection.textRanges.first else {
//            return
//        }
//
//        selectedFrame = .zero
//
//        textView.textLayoutManager?.enumerateTextSegments(in: textRange,
//                                                          type: .highlight,
//                                                          using: { range, frame, position, container in
//            guard frame.width > 0 else { return true }
//            selectedFrame = (selectedFrame ?? .zero).union(frame)
//            return true
//        })
//
//        guard selectedFrame != .zero else {
//            toolbarView.animator().isHidden = true
//            selectedFrame = nil
//            return
//        }
//        let frame = selectedFrame!
//
//
//        toolbarView.setFrameOrigin(.init(x: frame.origin.x + frame.width / 2 - 50,
//                                         y: frame.origin.y + frame.height + 4))
//        print(toolbarView.frame)
//        toolbarView.animator().isHidden = false
//    }
//
//
//
//    public func textView(_ textView: NSTextView,
//                         willChangeSelectionFromCharacterRange oldSelectedCharRange: NSRange,
//                         toCharacterRange newSelectedCharRange: NSRange) -> NSRange {
////        print("willChangeSelectionFromCharacterRange \(oldSelectedCharRange) to \(newSelectedCharRange)")
//        return newSelectedCharRange
//    }
//
}
//
//extension TrickleTextView.Coordinator: NSTextLayoutManagerDelegate {
//
//    public func textLayoutManager(_ textLayoutManager: NSTextLayoutManager,
//                                  textLayoutFragmentFor location: NSTextLocation,
//                                  in textElement: NSTextElement) -> NSTextLayoutFragment {
//        guard let textStorage = textView.textStorage,
//              let elementRange = textElement.elementRange else {
//            return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
//        }
//
//        let index = textLayoutManager.offset(from: textLayoutManager.documentRange.location, to: location)
//
//        guard index < textStorage.string.count else { return NSTextLayoutFragment(textElement: textElement, range: elementRange) }
////        let rawElementType = textStorage.attribute(.elementType, at: index, effectiveRange: nil) as? String
//        let rawBlockType = textStorage.attribute(.blockType, at: index, effectiveRange: nil) as? String
//
//        if let rawBlockType = rawBlockType {
//            switch rawBlockType {
//                case TrickleData.Block.BlockType.divider.rawValue:
//                    let divider = DividerLayoutFragment(textElement: textElement, range: elementRange)
//                    divider.width = self.textView.textLayoutManager?.usageBoundsForTextContainer.width
//                    return divider
//
//                default:
//                    break
//            }
//        }
//
////        if let elementType = rawElementType {
////            switch elementType {
////                case TrickleData.Element.ElementType.inlineCode.rawValue:
////                    let layoutFragment = InlineCodeLayoutFragment(textElement: textElement, range: elementRange)
////                    return layoutFragment
////
////                default:
////                    break
////            }
////        } else {
////            return EmptyLayoutFragment(textElement: textElement, range: elementRange)
////        }
//        let blockFragment = NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
////        DispatchQueue.main.async {
////            print(blockFragment.state.rawValue, blockFragment.renderingSurfaceBounds, blockFragment.layoutFragmentFrame, blockFragment.textElement, blockFragment.textLineFragments)
////        }
//        return blockFragment
//    }
//
//    #if os(macOS)
//
//    #endif
//}
#endif
