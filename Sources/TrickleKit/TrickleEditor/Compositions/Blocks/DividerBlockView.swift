//
//  DividerBlockView.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/23.
//

import SwiftUI

struct DividerBlockView: View {
    var block: TrickleData.Block
    var editable: Bool = true
    
    var focused: Binding<Bool>?
    @State private var localFocused: Bool = false
    
    private var isFocused: Binding<Bool> {
        Binding {
            localFocused
        } set: { val in
            localFocused = val
            if let focused = focused {
                focused.wrappedValue = val
            }
        }
    }
    
    var body: some View {
        VStack {
            Divider()
                .padding(4)
                .overlay(
                    isFocused.wrappedValue ?
                    ZStack {
                        RoundedRectangle(cornerRadius: 4).stroke(.indigo)
                        RoundedRectangle(cornerRadius: 4).fill(.indigo.opacity(0.2))
                    }.padding(1)
                    : nil
                )
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            #if os(macOS)
                .onChange(of: isFocused.wrappedValue) { newValue in
                    if newValue {
                        NSApp.keyWindow?.makeFirstResponder(nil)
                    }
                }
            #endif
                .onTapGesture {
                    isFocused.wrappedValue = true
                }
        }
    }
}
#if os(macOS)
final class DividerLayoutFragment: NSTextLayoutFragment {
    var width: CGFloat? = nil {
        didSet {
            self.invalidateLayout()
        }
    }
    
    override var leadingPadding: CGFloat {
        (self.width ?? .zero)
    }
    
    override var renderingSurfaceBounds: CGRect {
        guard let width = width else { return super.renderingSurfaceBounds }
        let newBounds = NSRect(x: super.renderingSurfaceBounds.midX - width,
                               y: super.renderingSurfaceBounds.minY,
                               width: width,
                               height: super.renderingSurfaceBounds.height)
        return newBounds
    }
    
    override func draw(at point: CGPoint, in context: CGContext) {
        // Draw the bubble and debug outline.
        context.saveGState()
//        context.move(to: point)
        let fillRect = NSRect(x: point.x, y: point.y + layoutFragmentFrame.height / 2,
                              width: width ?? layoutFragmentFrame.width,
                              height: 1)
        context.addRect(fillRect)
        context.setFillColor(NSColor.gray.cgColor)
        context.fillPath()
        context.restoreGState()
        
        super.draw(at: point, in: context)
    }
}

final class DividerTextAttachment: NSTextAttachment {

}
#endif


#if DEBUG
struct DividerBlockView_Previews: PreviewProvider {
    static var previews: some View {
        TrickleEditorView(blocks: .constant(load("blocks.json")))
        .padding()
    }
}
#endif
