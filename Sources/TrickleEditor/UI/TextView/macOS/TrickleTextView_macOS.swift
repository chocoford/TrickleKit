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

struct TrickleTextView: NSViewRepresentable {
    @EnvironmentObject var store: TrickleEditorStore
    
    @ObservedObject var config = Config()
    
    var height: Binding<CGFloat?>?
    var isFocus: Binding<Bool>?
    @State internal var focusState: Bool = false

    public init(height: Binding<CGFloat?>? = nil,
                isFocus: Binding<Bool>? = nil) {
        self.height = height
        self.isFocus = isFocus
    }
    
    public func makeNSView(context: Context) -> TTextView {
        let textView = context.coordinator.textView
        DispatchQueue.main.async {
            self.height?.wrappedValue = config.minHeight
        }
        return textView
    }
    
    public func updateNSView(_ textView: TTextView, context: Context) {
        textView.minSize = .init(width: textView.visibleRect.width, height: config.minHeight)
        DispatchQueue.main.async {
            context.coordinator.updateContentSize()
        }
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
    
    @State private var blocks: [TrickleBlock] = .default
    @State private var textViewHeight: CGFloat? = nil
    @State private var isFocused: Bool = true
    
    var body: some View {
//        VStack {
            TrickleTextView(height: $textViewHeight, isFocus: $isFocused)
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
