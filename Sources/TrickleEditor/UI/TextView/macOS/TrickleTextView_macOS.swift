//
//  TrickleTextView.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/15.
//
#if os(macOS)
import Foundation
import SwiftUI
import ChocofordUI
import AppKit
import TrickleCore

/*
struct TrickleTextView: NSViewRepresentable {
    typealias NSViewType = TTextView
    
    @Binding var text: AttributedString
    var font: NSFont
    var width: Binding<CGFloat>?
    var height: Binding<CGFloat>?
    var editable: Bool = true
    var focused: Binding<Bool>?

    var onKeydown: ((KeyboardEvent) -> Void)?
    
    @State private var isFocused: Bool = false
    
    func makeNSView(context: Context) -> NSViewType {
        let textView = context.coordinator.textView
        textView.textStorage?.append(NSAttributedString(text))
        textView.font = font
        textView.isEditable = editable
        textView.isSelectable = true
        textView.didFocused = {
            isFocused = true
        }
        DispatchQueue.main.async {
            if let height = height {
                height.wrappedValue = textView.intrinsicContentSize.height
            }
            if let width = width {
                width.wrappedValue = textView.intrinsicContentSize.width
            }
        }
        return textView
    }
    func updateNSView(_ textView: NSViewType, context: Context) {
        DispatchQueue.main.async {
            if let height = height {
                height.wrappedValue = textView.intrinsicContentSize.height
            }
            if let width = width {
                width.wrappedValue = textView.intrinsicContentSize.width
            }

            if let focused = focused {
                guard let window = textView.window else { return }
                if focused.wrappedValue {
                    guard !isFocused else { return }
                    // Make sure we know textfield has been focused.
                    window.makeFirstResponder(textView)
                    textView.setSelectedRange(NSRange.init(location: 0, length: 0))
                } else {
                    isFocused = false
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

extension TrickleTextView {
    class Coordinator: NSObject, NSTextViewDelegate {
        let textView = TTextView()

        var parent: TrickleTextView

        init(_ parent: TrickleTextView) {
            self.parent = parent
            super.init()
            textView.delegate = self
        }
        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            guard let eventHandler = self.parent.onKeydown else { return false }
            
            let localtion = textView.selectedRange().location
            let lineRect = textView.layoutManager?.lineFragmentRect(forGlyphAt: localtion, effectiveRange: nil) ?? .zero
            let lineHeight = lineRect.height
            let lineOrigin = lineRect.origin
            
            switch commandSelector {
                case #selector(NSStandardKeyBindingResponding.moveDown(_:)):
                    let shouldJump = lineOrigin.y + lineHeight >= textView.frame.height
                    guard shouldJump else { return false }
                    eventHandler(.arrowDown)
                case #selector(NSStandardKeyBindingResponding.moveUp(_:)):
                    let shouldJump = lineOrigin.y < lineHeight
                    guard shouldJump else { return false }
                    eventHandler(.arrowUp)
                case #selector(NSStandardKeyBindingResponding.insertNewline(_:)):
                    eventHandler(.enter)
                case #selector(NSStandardKeyBindingResponding.deleteBackward(_:)):
                    guard parent.text.characters.count == 0 else { fallthrough }
                    eventHandler(.deleteLine)
                default:
                    return false
            }
            return true
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            // Update text
            self.parent.text = AttributedString(textView.attributedString())
        }
        
        func textView(_ textView: NSTextView,
                      willChangeSelectionFromCharacterRange oldSelectedCharRange: NSRange,
                      toCharacterRange newSelectedCharRange: NSRange) -> NSRange {
            debugPrint("willChangeSelectionFromCharacterRange", oldSelectedCharRange, newSelectedCharRange)
            return newSelectedCharRange
        }
    }
}

class TTextField: NSTextField {
    var didFocused: (() -> Void)?
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    override func becomeFirstResponder() -> Bool {
        if let didFocused = didFocused {
            didFocused()
        }
        return true
    }
    override var acceptsFirstResponder: Bool {
        true
    }
    
}

class TTextView: NSTextView {
    var didFocused: (() -> Void)?
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    override func becomeFirstResponder() -> Bool {
        if let didFocused = didFocused {
            didFocused()
        }
        return true
    }

    override var intrinsicContentSize: NSSize {
        guard let container = self.textContainer else { return .zero }
        return self.layoutManager?.usedRect(for: container).size ?? .zero
    }

}
 */

public class TTextView: NSTextView {
    var didFocused: (() -> Void)?
    var minHeight: CGFloat = 14

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
//        return sharedTextStorage
//    }
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

struct TrickleTextView: NSViewRepresentable {
    @EnvironmentObject var textStorage: SharedTextContentStorage
    
    @ObservedObject var config = Config()
    
    @Binding var blocks: [TrickleData.Block]
    var height: Binding<CGFloat?>?
    var isFocus: Binding<Bool>?
    @State internal var focusState: Bool = false

    public init(blocks: Binding<[TrickleData.Block]>, height: Binding<CGFloat?>? = nil, isFocus: Binding<Bool>? = nil) {
        self._blocks = blocks
        self.height = height
        self.isFocus = isFocus
    }
    
    public func makeNSView(context: Context) -> TTextView {
        print("makeNSView")
        let textView = context.coordinator.textView
        print("textStorage", blocks, blocks.toAttributedString())
        textView.textContentStorage?.textStorage?.insert(.init(blocks.toAttributedString()), at: 0)
        return textView
    }
    
    public func updateNSView(_ textView: TTextView, context: Context) {
        textView.minSize = .init(width: textView.visibleRect.width, height: config.minHeight)
//        textView.textContainerInset = NSSize(width: 8, height: 8)
        DispatchQueue.main.async {
            context.coordinator.updateContentSize()
        }
//        DispatchQueue.main.async {
//            if isFocus?.wrappedValue == true && !focusState {
//                let becomeFirstResponder = textView.becomeFirstResponder()
//                print("becomeFirstResponder", becomeFirstResponder)
//            } else if isFocus?.wrappedValue == false && focusState {
//                textView.resignFirstResponder()
//                print("resignFirstResponder")
//            }
//        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// MARK: - Functions
extension TrickleTextView {
    
}



#if DEBUG
struct TrickleTextMacOSPreviewView: View {
    var minHeight: CGFloat = 72
    
    var height: Binding<CGFloat>?
    
    @State private var blocks: [TrickleData.Block] = .default
    @State private var textViewHeight: CGFloat? = nil
    @State private var isFocused: Bool = true
    
    var body: some View {
//        VStack {
            TrickleTextView(blocks: $blocks, height: $textViewHeight, isFocus: $isFocused)
                .minHeight(minHeight)
                .frame(height: max(minHeight, textViewHeight ?? 0))
//                .animation(.default, value: height)
//                .environmentObject(SharedTextContentStorage())
//        }
//        .background(Color.textBackgroundColor)
//        .frame(height: max(minHeight, height ?? 0))
    }
}

struct TrickleTextView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TrickleTextMacOSPreviewView()
//            Divider()
//            TrickleTextMacOSPreviewView()
//            TextEditor(text: .constant("123"))
//            TextField("", text: .constant(""))
        }
        .frame(height: 400)
    }
}
#endif

#endif
