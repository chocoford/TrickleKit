//
//  TrickleTextView.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/15.
//

import SwiftUI
import TrickleCore
#if os(macOS)
import AppKit
#elseif os(iOS)

#endif

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
enum KeyboardEvent {
    case arrowUp //(NSEvent)
    case arrowDown //(NSEvent)
    case enter //(NSEvent)
    case deleteLine
}

struct TrickleTextView {
    @EnvironmentObject var textStorage: SharedTextContentStorage
    
    @Binding var blocks: [TrickleData.Block]
    var width: Binding<CGFloat>?
    var height: Binding<CGFloat?>?
    var editable: Bool
    
}

#if os(macOS)
public class TTextView: NSTextView {
    var sharedTextStorage: NSTextContentStorage? {
        didSet {
            // important
            if let textLayoutManager = textLayoutManager {
                sharedTextStorage?.addTextLayoutManager(textLayoutManager)
            }
        }
    }
//    var _textContentStorage: NSTextContentStorage?
    var didFocused: (() -> Void)?
    
//    init(textContentStorage: NSTextContentStorage) {
//        self._textContentStorage = textContentStorage
//    }
    
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
        return true
    }
    
//    public override var textStorage: NSTextStorage? {
//        return sharedTextStorage
//    }
    
    public override var textContentStorage: NSTextContentStorage? {
        return sharedTextStorage
    }
    

    // override this method will cause fall into TextKit 1.
//    public override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
//    }

//    public override var intrinsicContentSize: NSSize {
//        guard let container = self.textContainer else { return .zero }
//        return self.layoutManager?.usedRect(for: container).size ?? .zero
//    }
}

extension TrickleTextView: NSViewRepresentable {
    public typealias NSViewType = NSScrollView
    
    public init(blocks: Binding<[TrickleData.Block]>, height: Binding<CGFloat?>?, editable: Bool = true) {
        self._blocks = blocks
        self.height = height
        self.editable = editable
    }
    
    public func makeNSView(context: Context) -> NSViewType {
        let textView = context.coordinator.editorView
        DispatchQueue.main.async {
            context.coordinator.updateContentSize()
        }
        return textView
    }
    
    public func updateNSView(_ textView: NSViewType, context: Context) {
        let textView = context.coordinator.textView
        textView.isEditable = editable
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// MARK: - Functions
extension TrickleTextView {

}

// MARK: - Coordinator
extension TrickleTextView {
    public class Coordinator: NSObject {
        let editorView: NSViewType
        let textView: TTextView
        
        var parent: TrickleTextView
        
        var selectedFrame: NSRect? = nil
        
        lazy var toolbarView: NSView = {
            let view = NSHostingView(rootView: ToolbarView())
            view.setFrameSize(.init(width: 100, height: 40))
            view.isHidden = true
            return view
        }()
        
        init(_ parent: TrickleTextView) {
            self.editorView = TTextView.scrollableTextView()
            self.textView = editorView.documentView as! TTextView
            self.textView.sharedTextStorage = parent.textStorage
            
            
            self.parent = parent
            super.init()
            editorView.drawsBackground = false
            textView.drawsBackground = false
            
            textView.delegate = self
            textView.textLayoutManager?.delegate = self
            assert(textView.textLayoutManager != nil, "textLayoutManager is nil")

            DispatchQueue.main.async {
//                print(textView.textLayoutManager.)
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
        
        func updateContentSize() {
            var height: CGFloat = 0
            textView.textLayoutManager?.enumerateTextLayoutFragments(from: textView.textLayoutManager?.documentRange.endLocation,
                                                                     options: [.reverse, .ensuresLayout]) { layoutFragment in
                height = layoutFragment.layoutFragmentFrame.maxY
                return false // stop
            }
            if let textViewHeight = self.parent.height {
                textViewHeight.wrappedValue = height
            }
        }
    }
}

extension TrickleTextView.Coordinator: NSTextViewDelegate {
    public func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else {
            return
        }
        parent.blocks = textView.attributedString().toBlocks()
        DispatchQueue.main.async {
            self.updateContentSize()
        }
    }
    
    public func textViewDidChangeSelection(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView,
              let textLayoutManager = textView.textLayoutManager,
              let selection = textLayoutManager.textSelections.first,
              let textRange = selection.textRanges.first else {
            return
        }
        
        selectedFrame = .zero
        
        textView.textLayoutManager?.enumerateTextSegments(in: textRange,
                                                          type: .highlight,
                                                          using: { range, frame, position, container in
            guard frame.width > 0 else { return true }
            selectedFrame = (selectedFrame ?? .zero).union(frame)
            return true
        })
        
        guard selectedFrame != .zero else {
            toolbarView.animator().isHidden = true
            selectedFrame = nil
            return
        }
        let frame = selectedFrame!
        
        
        toolbarView.setFrameOrigin(.init(x: frame.origin.x + frame.width / 2 - 50,
                                         y: frame.origin.y + frame.height + 4))
        print(toolbarView.frame)
        toolbarView.animator().isHidden = false
    }
    
    
    
    public func textView(_ textView: NSTextView,
                         willChangeSelectionFromCharacterRange oldSelectedCharRange: NSRange,
                         toCharacterRange newSelectedCharRange: NSRange) -> NSRange {
//        print("willChangeSelectionFromCharacterRange \(oldSelectedCharRange) to \(newSelectedCharRange)")
        return newSelectedCharRange
    }
    
}

extension TrickleTextView.Coordinator: NSTextLayoutManagerDelegate {
    
    public func textLayoutManager(_ textLayoutManager: NSTextLayoutManager,
                                  textLayoutFragmentFor location: NSTextLocation,
                                  in textElement: NSTextElement) -> NSTextLayoutFragment {
        guard let textStorage = textView.textStorage,
              let elementRange = textElement.elementRange else {
            return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
        }

        let index = textLayoutManager.offset(from: textLayoutManager.documentRange.location, to: location)

        guard index < textStorage.string.count else { return NSTextLayoutFragment(textElement: textElement, range: elementRange) }
//        let rawElementType = textStorage.attribute(.elementType, at: index, effectiveRange: nil) as? String
        let rawBlockType = textStorage.attribute(.blockType, at: index, effectiveRange: nil) as? String
        
        if let rawBlockType = rawBlockType {
            switch rawBlockType {
                case TrickleData.Block.BlockType.divider.rawValue:
                    let divider = DividerLayoutFragment(textElement: textElement, range: elementRange)
                    divider.width = self.textView.textLayoutManager?.usageBoundsForTextContainer.width
                    return divider
                    
                default:
                    break
            }
        }

//        if let elementType = rawElementType {
//            switch elementType {
//                case TrickleData.Element.ElementType.inlineCode.rawValue:
//                    let layoutFragment = InlineCodeLayoutFragment(textElement: textElement, range: elementRange)
//                    return layoutFragment
//
//                default:
//                    break
//            }
//        } else {
//            return EmptyLayoutFragment(textElement: textElement, range: elementRange)
//        }
        let blockFragment = NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
//        DispatchQueue.main.async {
//            print(blockFragment.state.rawValue, blockFragment.renderingSurfaceBounds, blockFragment.layoutFragmentFrame, blockFragment.textElement, blockFragment.textLineFragments)
//        }
        return blockFragment
    }
    
    #if os(macOS)
    
    #endif
}

#elseif os(iOS)
extension TrickleTextView: UIViewRepresentable {
    func makeUIView(context: Context) -> UITextField {
        return UITextField()
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        
    }
}
#endif

 #if DEBUG
struct TrickleTextView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            
        }
    }
}
#endif
