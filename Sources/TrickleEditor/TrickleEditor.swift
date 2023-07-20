import SwiftUI
import TrickleCore

public struct TrickleEditor: View {
    @ObservedObject var store: TrickleEditorStore
    
    public init(store: TrickleEditorStore = .init()) {
        self.store = store
    }
    
    private var config: Config = .init()

    @State private var textViewHeight: CGFloat? = nil
    @State private var isFocused: Bool = true
    
    var showPlaceholder: Bool {
        return !config.placeholder.isEmpty && (store.textContentStorage.attributedString == nil || store.textContentStorage.attributedString?.length == 0)
    }
    
    public var body: some View {
        TrickleTextView(height: $textViewHeight, isFocus: $isFocused)
            .minHeight(config.minHeight)
            .frame(height: textViewHeight == nil ? config.minHeight : textViewHeight)
            .frame(minHeight: config.minHeight)
            .animation(.default, value: textViewHeight)
            .environmentObject(store)
            .overlay(alignment: .topLeading) {
                if showPlaceholder {
                    Text(config.placeholder)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8) // hardcode
                        .padding(.horizontal, 4)
                        .allowsHitTesting(false)
                }
            }
    }
}


extension TrickleEditor {
    final class Config: ObservableObject {
        @Published var placeholder: String = ""
        @Published var minHeight: CGFloat = 14 + 16
    }
    
    public func placeholder(_ string: String) -> TrickleEditor {
        self.config.placeholder = string
        return self
    }
    
    public func minHeight(_ height: CGFloat) -> TrickleEditor {
        self.config.minHeight = height
        return self
    }
}

public extension TrickleEditor {
    @ViewBuilder
    static func renderBlocks<S: Sequence>(_ blocks: S, baseFontSize: CGFloat = 16) -> some View where S.Element == TrickleBlock {
        BlocksRenderer(blocks: blocks, baseFontSize: baseFontSize)
    }
}

#if DEBUG
struct TrickleEditor_Previews: PreviewProvider {
    static var previews: some View {
        TrickleEditor()
            .placeholder("Send a message and request to create...")
    }
}
#endif
