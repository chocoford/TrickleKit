//
//  File.swift
//  
//
//  Created by Chocoford on 2023/6/5.
//
#if os(macOS)
import Foundation
import AppKit
import SwiftUI
import Combine

public class TTextView: NSTextView {
    var didFocused: (() -> Void)?
    var minHeight: CGFloat = 14
    
    internal var _textContentStorage: NSTextContentStorage?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    public override func becomeFirstResponder() -> Bool {
        if let didFocused = didFocused {
            didFocused()
        }
        return super.becomeFirstResponder() // <-- important
    }
    
//    public override var textStorage: NSTextStorage? {
//        return sharedTextStorage
//    }
    
    
//    public override var textContentStorage: NSTextContentStorage? {
//        return _textContentStorage
//    }
    
    public func setTextContentStorage(_ textContentStorage: NSTextContentStorage) {
        self._textContentStorage = textContentStorage
    }
//

    // override this method will cause fall into TextKit 1.
//    public override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
//    }
    
//    public override var minSize: NSSize {
//        .init(width: self.visibleRect.width, height: 200)
//    }

//    public override var intrinsicContentSize: NSSize {
////        guard let container = self.textContainer else { return .zero }
////        return self.layoutManager?.usedRect(for: container).size ?? .zero
////        var height: CGFloat = 0
////        textLayoutManager?.enumerateTextLayoutFragments(from: textLayoutManager?.documentRange.endLocation,
////                                                                 options: [.reverse, .ensuresLayout]) { layoutFragment in
////            height = layoutFragment.layoutFragmentFrame.maxY
////            return false // stop
////        }
////        let intrinsicContentSize = NSSize(width: max(100, super.intrinsicContentSize.width), height: max(height, minHeight))
////        print("intrinsicContentSize: ", intrinsicContentSize)
//        return .init(width: self.visibleRect.width, height: 200)//intrinsicContentSize // super.intrinsicContentSize //
//    }
}


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
        
        var cancellable: AnyCancellable?
        
        init(_ parent: TrickleTextView) {
            self.editorView = TextView.scrollableTextView()
            self.textView = TextView(frame: .zero, textContainer: parent.store.textContainer) //editorView.documentView as! TextView
            self.parent = parent
            super.init()
//            editorView.drawsBackground = false
            textView.drawsBackground = false

            self.textView.delegate = self
            self.parent.store.delegate = self
            self.textView.setFrameSize(.init(width: self.textView.frame.width, height: self.parent.config.minHeight))
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
//            print("updateContentSize")
        }
    }
}
//
extension TrickleTextView.Coordinator: NSTextViewDelegate {
    public func textDidChange(_ notification: Notification) {
        guard let _ = notification.object as? TextView else {
            return
        }
        DispatchQueue.main.async {
            self.updateContentSize()
        }
    }
    
    public func textDidEndEditing(_ notification: Notification) {
        guard let _ = notification.object as? TextView else {
            return
        }
        self.parent.isFocus?.wrappedValue = false
        self.parent.focusState = false
    }
    
    public func textView(_ textView: NSTextView, willDisplayToolTip tooltip: String, forCharacterAt characterIndex: Int) -> String? {
        "Tooltip"
    }
    
    public func textView(_ textView: NSTextView, willShow servicePicker: NSSharingServicePicker, forItems items: [Any]) -> NSSharingServicePicker? {
        print("textView willShow servicePicker", servicePicker, items)
        return servicePicker
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

extension TrickleTextView.Coordinator: TrickleEditorStoreDelegate {
    public func textContentStorageDidChanged() {
        DispatchQueue.main.async {
            self.updateContentSize()
        }
    }
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
//                case TrickleBlock.BlockType.divider.rawValue:
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
////                case TrickleElement.ElementType.inlineCode.rawValue:
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
