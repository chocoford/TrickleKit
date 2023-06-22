import SwiftUI
import TrickleCore

public struct TrickleEditor: View {
    @ObservedObject var store: TrickleEditorStore
    var minHeight: CGFloat
    
    public init(store: TrickleEditorStore = .init(), minHeight: CGFloat = 72) {
        self.store = store
        self.minHeight = minHeight
    }

    @State private var textViewHeight: CGFloat? = nil
    @State private var isFocused: Bool = true
    
    public var body: some View {
        TrickleTextView(height: $textViewHeight, isFocus: $isFocused)
            .minHeight(minHeight)
            .frame(height: textViewHeight)
            .frame(minHeight: minHeight)
            .animation(.default, value: textViewHeight)
            .environmentObject(store)
    }
}
