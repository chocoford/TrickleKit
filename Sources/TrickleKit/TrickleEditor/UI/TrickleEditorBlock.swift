//
//  TrickleEditorBlock.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/23.
//

import SwiftUI

struct TrickleEditorBlock: View {
    @Binding var text: AttributedString
    #if os(macOS)
    var font: NSFont
    #elseif os(iOS)
    var font: UIFont
    #endif
    var editable: Bool
    @Binding var focused: Bool
    var onKeydown: ((KeyboardEvent) -> Void)?
    
    @State private var height: CGFloat = .zero
    @State private var width: CGFloat = .zero
    
    @State private var maxWidth: CGFloat? = nil
    
    var realWidth: CGFloat? {
        if editable { return nil }
        if width == .zero {
            return nil
        } else if let maxWidth = maxWidth {
            return min(width, maxWidth)
        }
        return nil
    }
    
    var body: some View {
        textContent
    }
    
    @ViewBuilder private var textContent: some View {
        if editable {
//            TrickleTextView(text: $text,
//                             font: font,
//                             width: $width,
//                             height: $height,
//                             editable: editable,
//                             focused: $focused,
//                             onKeydown: onKeydown)
            Text("")
            .frame(width: nil, height: height)
            .background(
                GeometryReader { geometry  in
                    Color.clear
                        .onAppear {
                            maxWidth = geometry.size.width
                        }
                }
            )
        } else {
            Text(text)
                .textSelection(.enabled)
                .font(Font(font))
        }
    }
}


#if DEBUG
struct TrickleEditorBlock_Previews: PreviewProvider {
    static var previews: some View {
        TrickleEditorView(blocks: .constant([.init(type: .richText, elements: [
            .init(.text, text: "akjdlakjlakkjsdlaweqweqweqwe")
        ])]))
//        .frame(height: 100)
    }
}
#endif
