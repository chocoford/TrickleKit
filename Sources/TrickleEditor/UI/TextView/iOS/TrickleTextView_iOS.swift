//
//  SwiftUIView.swift
//  
//
//  Created by Dove Zachary on 2023/6/5.
//
#if os(iOS)
import SwiftUI
import TrickleCore

struct TrickleTextView: UIViewRepresentable {
    @EnvironmentObject var store: TrickleEditorStore

    @ObservedObject var config = Config()
    
    var height: Binding<CGFloat?>?
    var isFocus: Binding<Bool>?
    @State internal var focusState: Bool = false

    public init(height: Binding<CGFloat?>? = nil, isFocus: Binding<Bool>? = nil) {
        self.height = height
        self.isFocus = isFocus
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = context.coordinator.textView
        DispatchQueue.main.async {
            self.height?.wrappedValue = config.minHeight
        }
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.updateContentSize()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

#if DEBUG
struct TrickleTextPreviewView: View {
    var minHeight: CGFloat = 72
    
    var height: Binding<CGFloat>?
    
    @State private var blocks: [TrickleBlock] = .default
    @State private var textViewHeight: CGFloat? = nil
    @State private var isFocused: Bool = true
    
    var body: some View {
        TrickleTextView(height: $textViewHeight, isFocus: $isFocused)
            .minHeight(minHeight)
            .frame(height: max(minHeight, textViewHeight ?? 0))
            .environmentObject(TrickleEditorStore())
    }
}

struct TrickleTextView_Previews: PreviewProvider {
    static var previews: some View {
        TrickleTextPreviewView()
    }
}
#endif
#endif
