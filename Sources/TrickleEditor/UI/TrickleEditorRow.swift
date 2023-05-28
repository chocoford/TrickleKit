//
//  TrickleEditorRow.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/15.
//

import SwiftUI
import Shimmer
import ChocofordUI
import ChocofordEssentials
import TrickleCore

struct TrickleEditorRow: View {
    @EnvironmentObject var config: TrickleEditorConfig

    @Binding var block: TrickleData.Block
    var editable: Bool {
        config.editable
    }
    var showActions: Bool {
        config.showRowActions
    }
//    var namespace: Namespace.ID
    @Binding var focused: Bool

    var onKeydown: ((KeyboardEvent) -> Void)?
    
    @State private var isHover: Bool = false
        
    var text: Binding<AttributedString> {
        Binding {
            block.elements?
                .map { element in
                    try! AttributedString(markdown: TrickleEditorParser.parseElement(element: element))
                }
                .reduce(.init(""), +) ?? .init("")
        } set: { val in
            block.elements?[0].text = String(val.characters)
        }

    }
    
    var body: some View {
        HStack(spacing: 2) {
            handler
#if os(macOS)
            BlockView(block: $block, isSelected: false, tag: 0)
#endif
        }
        .onHover { hover in
            withAnimation {
                isHover = hover
            }
        }
    }
}

extension TrickleEditorRow {
#if os(macOS)
    typealias Font = NSFont
#elseif os(iOS)
    typealias Font = UIFont
#endif
    
    @ViewBuilder private var handler: some View {
        HStack {
            Button {
                
            } label: {
                Image(systemName: "plus")
            }
            
            Button {
                
            } label: {
                Image("sircle.grid.2x3.fill")
            }
        }
        //            .matchedGeometryEffect(id: tag, in: namespace)
        .buttonStyle(.borderless)
        .opacity(isHover ? 1 : 0)
    }
    
    @ViewBuilder
    private var blockRenderer: some View {
        switch block.type {
            case .richText:
                TrickleEditorBlock(text: text, font: Font.systemFont(ofSize: config.baseFontSize), editable: editable, focused: $focused, onKeydown: onKeydown)
                
            case .h1:
                TrickleEditorBlock(text: text, font: Font.boldSystemFont(ofSize: config.baseFontSize * 2), editable: editable, focused: $focused, onKeydown: onKeydown)
                
            case .h2:
                TrickleEditorBlock(text: text, font: Font.boldSystemFont(ofSize: config.baseFontSize * 1.75), editable: editable, focused: $focused, onKeydown: onKeydown)
                
            case .h3:
                TrickleEditorBlock(text: text, font: Font.boldSystemFont(ofSize: config.baseFontSize * 1.5), editable: editable, focused: $focused, onKeydown: onKeydown)
                
            case .h4:
                TrickleEditorBlock(text: text, font: Font.boldSystemFont(ofSize: config.baseFontSize * 1.375), editable: editable, focused: $focused, onKeydown: onKeydown)
                
            case .h5:
                TrickleEditorBlock(text: text, font: Font.boldSystemFont(ofSize: config.baseFontSize * 1.25), editable: editable, focused: $focused, onKeydown: onKeydown)
                
            case .h6:
                TrickleEditorBlock(text: text, font: Font.boldSystemFont(ofSize: config.baseFontSize * 1.125), editable: editable, focused: $focused, onKeydown: onKeydown)
                
            case .checkbox:
                CheckboxBlockView(block: block, text: text, editable: editable, focused: $focused, onKeydown: onKeydown)
                    
            case .list, .numberedList:
                ListBlockView(block: block, text: text, editable: editable, focused: $focused, onKeydown: onKeydown)
     
            case .gallery:
                SingleAxisGeometryReader(axis: .horizontal) { width in
                    GalleryBlockView(block: block, focused: $focused, onKeydown: onKeydown)
                        .frame(width: width, height: width * 9 / 16)
                }
                
            case .embed:
                EmbedBlockView(block: block)
                
            case .file:
                FileBlockView(block: block)
                
            case .quote:
                QuoteBlockView(block: block)
                
            case .code:
                CodeBlockView(block: block)
                
            case .webBookmark:
                WebBookmarkBlockView(block: block)
                
            case .divider:
                DividerBlockView(block: block, editable: editable, focused: $focused)
                    .handleKeydown(onKeydown)
            default:
                errorBlock(block)
        }
    }
    
    
    
    @ViewBuilder private func errorBlock(_ block: TrickleData.Block) -> some View {
        Text("Unsupported block: \(block.type.description)")
            .foregroundColor(.red)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 4).fill(.red.opacity(0.1))
            )
            .padding(2)
    }
}

fileprivate extension View {
    @ViewBuilder func handleKeydown(_ onKeydown: ((KeyboardEvent) -> Void)?) -> some View {
        if let onKeydown = onKeydown {
            background(
                Group {
                    Button(action: { onKeydown(.enter) }) {}
                        .keyboardShortcut(.escape, modifiers: [])
                    Button(action: { onKeydown(.arrowUp) }) {}
                        .keyboardShortcut(.upArrow, modifiers: [])
                    Button(action: { onKeydown(.arrowDown)}) {}
                        .keyboardShortcut(.downArrow, modifiers: [])
                }.opacity(0)
            )
        }
    }
}

extension TrickleEditorRow {
    @ViewBuilder
    public func editorSetting(version: TrickleEditorConfig.Version = .v1,
                              selectable: Bool = true,
                              editable: Bool = true,
                              scrollable: Bool = true,
                              isSending: Bool = false,
                              singleLine: Bool = false,
                              showToolbar: Bool = true,
                              rounded: Bool = true,
                              showRowActions: Bool = true,
                              baseFontSize: CGFloat = 16,
                              maxHeight: CGFloat? = nil) -> some View {
        environmentObject(TrickleEditorConfig(version: version,
                                              selectable: selectable,
                                              editable: editable,
                                              scrollable: scrollable,
                                              isSending: isSending,
                                              singleLine: singleLine,
                                              showToolbar: showToolbar,
                                              rounded: rounded,
                                              showRowActions: showRowActions,
                                              baseFontSize: baseFontSize,
                                              maxHeight: maxHeight))
    }
    
    @ViewBuilder
    public func readOnly(version: TrickleEditorConfig.Version = .v1,
                         selectable: Bool = true,
                         scrollable: Bool = true, baseFontSize: CGFloat = 16) -> some View {
        environmentObject(TrickleEditorConfig(version: version,
                                              selectable: selectable,
                                              editable: false,
                                              scrollable: scrollable,
                                              isSending: false,
                                              singleLine: false,
                                              showToolbar: false,
                                              rounded: false,
                                              showRowActions: false,
                                              baseFontSize: baseFontSize,
                                              maxHeight: nil))
    }
}

#if DEBUG
struct TrickleEditorRow_Previews: PreviewProvider {
    static var previews: some View {
        TrickleEditorView(blocks: .constant(load("blocks.json")))
    }
}
#endif
