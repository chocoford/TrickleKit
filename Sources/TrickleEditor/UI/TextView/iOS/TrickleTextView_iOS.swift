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
    
    func makeUIView(context: Context) -> UITextView {
        return context.coordinator.textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

#if DEBUG
struct TrickleTextPreviewView: View {
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
        TrickleTextPreviewView()
    }
}
#endif
#endif
