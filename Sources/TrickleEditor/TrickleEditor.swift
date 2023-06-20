import SwiftUI
import TrickleCore

public struct TrickleEditor: View {
    @Binding var blocks: [TrickleData.Block]
    var minHeight: CGFloat
    
    public init(blocks: Binding<[TrickleData.Block]>, minHeight: CGFloat = 72) {
        self._blocks = blocks
        self.minHeight = minHeight
    }

    @State private var textViewHeight: CGFloat? = nil
    @State private var isFocused: Bool = true
    
    public var body: some View {
        TrickleTextView(blocks: $blocks, height: $textViewHeight, isFocus: $isFocused)
            .minHeight(minHeight)
            .frame(height: textViewHeight)
            .frame(minHeight: minHeight)
            .animation(.default, value: textViewHeight)
            .environmentObject(SharedTextContentStorage())
    }
}
