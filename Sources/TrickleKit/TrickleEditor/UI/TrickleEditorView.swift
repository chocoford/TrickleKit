//
//  TrickleEditorView.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/14.
//

import SwiftUI
import ChocofordUI

public class TrickleEditorConfig: ObservableObject {
    static var `default` = TrickleEditorConfig(version: .v0,
                                               selectable: true,
                                               editable: true,
                                               scrollable: true,
                                               isSending: false,
                                               singleLine: false,
                                               showToolbar: false,
                                               rounded: false,
                                               showRowActions: true,
                                               baseFontSize: 16)
    
    public enum Version {
        case v0
        case v1
        case v2
    }
    
    var version: Version = .v0
    
    var editable: Bool = true
    var selectable: Bool = true
    var scrollable: Bool = true
    var isSending: Bool = false
    var singleLine: Bool = false
    var showToolbar: Bool = true
    var rounded: Bool = true
    var showRowActions: Bool = true
    
    
    var baseFontSize: CGFloat = 16
    var maxHeight: CGFloat?
    
    var onSend: (([TrickleData.Block]) -> Void)?
        
    public init(version: Version,
                selectable: Bool,
                editable: Bool, scrollable: Bool,
                isSending: Bool, singleLine: Bool,
                showToolbar: Bool, rounded: Bool,
                showRowActions: Bool,
                baseFontSize: CGFloat,
                maxHeight: CGFloat? = nil) {
        self.version = version
        
        self.editable = editable
        self.scrollable = scrollable
        self.isSending = isSending
        self.singleLine = singleLine
        self.showToolbar = showToolbar
        self.rounded = rounded
        self.showRowActions = showRowActions
        self.baseFontSize = baseFontSize
        self.maxHeight = maxHeight
    }
}

public struct TrickleEditorView: View {
    @ObservedObject var config: TrickleEditorConfig = .default

    @Binding var blocks: [TrickleData.Block]
    
    @StateObject private var textStorage = SharedTextContentStorage()
    
    public init(blocks: Binding<[TrickleData.Block]>) {
        self._blocks = blocks
    }
    
    @State private var focusedRow: Int = -1
    @State private var minHeight: CGFloat = 40
    @State private var textViewHeight: CGFloat? = nil
    
    @State private var inputText: String = ""
    
    public var body: some View {
        switch config.version {
            case .v0:
                v0Editor
                
            case .v1:
                v1Editor
                
            case .v2:
                v2Editor
        }
    }
    
    @ViewBuilder private func containerView<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        if config.scrollable {
            ScrollView {
                SingleAxisGeometryReader(axis: .horizontal, alignment: .leading) { width in
                    VStack(alignment: .leading, spacing: 0) {
                        content()
                        emptyArea(width: width)
                    }
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear.onChange(of: geometry.size) { newValue in
                            minHeight = newValue.height
                        }
                    }
                )
            }
            .frame(minHeight: config.maxHeight != nil ? min(config.maxHeight!, minHeight) : nil)
        } else {
            VStack(alignment: .leading, spacing: 0) {
                content()
            }
        }
        
    }
    
    @ViewBuilder private var blockRowsView: some View {
        //        TrickleTextView(blocks: $blocks)
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array($blocks.enumerated()), id: \.element.wrappedValue.id) { i, $block in
                let tag: Int = i // + 1
                let focused: Binding<Bool> = Binding {
                    focusedRow == tag
                } set: { isFocus in
                    if isFocus {
                        focusedRow = tag
                    }
                }
                
                TrickleEditorRow(block: $block, focused: focused) { event in
                    switch event {
                        case .enter:
                            if config.singleLine {
                                post()
                            } else {
                                newLine()
                            }
                        case .arrowUp:
                            focusedRow = max(0, tag - 1)
                        case .arrowDown:
                            focusedRow = min(blocks.count - 1, tag + 1)
                        case .deleteLine:
                            deleteLine()
                    }
                }
                .environmentObject(config)
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - V0: plain text editor only
extension TrickleEditorView {
    @ViewBuilder
    private var v0Editor: some View {
//        let _ = print("render v0Editor. editable: \(config.editable)")
        if config.editable {
            HStack {
                TextEditor(text: $inputText)
                    .padding(4)
                    .onChange(of: inputText) { newValue in
                        blocks = TrickleEditorParser.formBlock(string: newValue)
                    }
#if os(macOS)
                VStack {
                    Spacer(minLength: 0)
                    Button {
                        if let onSend = config.onSend {
                            onSend(blocks)
                        }
                    } label: {
                        Image(systemName: "paperplane")
                            .padding(4)
                    }
                    .buttonStyle(.borderless)
                }
#endif
            }
            .background(Color.textBackgroundColor)
            .frame(height: 40)
        } else {
            TrickleEditorParser.parse(blocks, baseFontSize: config.baseFontSize)
        }
    }
}


// MARK: - V1: plain text editor with previews
extension TrickleEditorView {
//    var blocksText: Binding<String> {
//        Binding {
//            return blocks.toRawText()
//        } set: { val in
//            blocks = TrickleEditorParser.formBlock(string: val)
//        }
//    }
    
    @ViewBuilder
    /// Editor v1: plain text editor with previews
    private var v1Editor: some View {
        if config.editable {
            #if os(macOS)
            HSplitView {
                ScrollView {
                    TextEditor(text: $inputText)
                        .onChange(of: inputText) { newValue in
                            blocks = TrickleEditorParser.formBlock(string: newValue)
                        }
                }
                
                ScrollView {
                    HStack {
                        TrickleEditorParser.parse(blocks, baseFontSize: config.baseFontSize)
                        Spacer(minLength: 0)
                    }
                }
            }
            #elseif os(iOS)
            
            #endif
        } else {
            TrickleEditorParser.parse(blocks, baseFontSize: config.baseFontSize)
        }
    }
}

// MARK: - V2: an overall rich NSTextView
extension TrickleEditorView {
    @ViewBuilder
    /// Editor v2:  an overall rich NSTextView
    private var v2Editor: some View {
        VStack(alignment: .leading, spacing: 0) {
            TrickleTextView(blocks: $blocks, height: $textViewHeight, editable: config.editable)
                .environmentObject(textStorage)
                .frame(height: config.maxHeight == nil ? textViewHeight : textViewHeight != nil ? min(config.maxHeight!, textViewHeight!) : 300)
                .onAppear { textStorage.blocks = blocks }
            if config.showToolbar {
                toolbar
            }
        }
        .padding(8)
        .background(Color.textBackgroundColor,
                    in: RoundedRectangle(cornerRadius: config.rounded ? 8 : 0))
    }
}




extension TrickleEditorView {
    @ViewBuilder private var toolbar: some View {
        HStack {
            Button {
#if os(macOS)
                importImage()
#endif
            } label: {
                Image(systemName: "photo")
            }
            Spacer()
            
            if config.isSending == true {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                Button {
                    post()
                } label: {
                    Image(systemName: "paperplane.fill")
                }
            }
 
        }
        .animation(.default, value: config.isSending)
        .buttonStyle(.borderless)
    }
    
    /**
     An area where click will add a new line
     */
    @ViewBuilder private func emptyArea(width: CGFloat) -> some View {
        if !config.singleLine && config.editable {
            Spacer()
                .frame(width: width)
                .frame(minHeight: 200)
                .contentShape(Rectangle())
            #if os(macOS)
                .onTapGesture {
                    if focusedRow == -1 {
                        newLine()
                    } else {
                        focusedRow = -1
                        NSApp.keyWindow?.makeFirstResponder(nil)
                    }
                }
            #endif
        }
    }
}

extension TrickleEditorView {
    func post() {
        if let onSend = config.onSend { onSend(blocks) }
        blocks = .default
    }
    
    func newLine(block: TrickleData.Block = .default) {
        withAnimation {
            if focusedRow == -1 {
                focusedRow = blocks.count
            } else {
                focusedRow += 1
            }
            blocks.insert(block, at: focusedRow)
        }
    }
    
    func deleteLine() {
        print("delete line at \(focusedRow)")
        withAnimation {
            guard focusedRow > 0 else { return }
            blocks.remove(at: focusedRow)
            focusedRow -= 1
        }
    }
    
#if os(macOS)
    func importImage() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image]
        if panel.runModal() == .OK, let url = panel.url {
            let filename = url.lastPathComponent
            do {
                if let url = panel.url {
                    let data = try Data(contentsOf: url)
                    var imgWidth: CGFloat = 0
                    var imgHeight: CGFloat = 0
                    if let imgSouce = CGImageSourceCreateWithURL(url as CFURL, nil),
                       let header = CGImageSourceCopyPropertiesAtIndex(imgSouce, 0, nil) as? Dictionary<String, Any> {
                        imgWidth = header["PixelWidth"] as? CGFloat ?? 0
                        imgHeight = header["PixelHeight"] as? CGFloat ?? 0
                    }
                    
                    let imageElementValue: TrickleData.Element.ImageElementValue = .local(.init(filename: filename,
                                                                                                localSrc: data,
                                                                                                naturalWidth: imgWidth,
                                                                                                naturalHeight: imgHeight))
                    let galleryBlock = TrickleData.Block(type: .gallery,
                                                         elements: [
                                                            .init(.image,
                                                                  value: .galleryImageValue(imageElementValue))
                                                         ])
                    newLine(block: galleryBlock)
                }
            } catch {
                dump(error)
            }
        }
    }
#endif
}


extension TrickleEditorView {
    public func selectable(_ flag: Bool = true) -> TrickleEditorView {
        self.config.selectable = flag
        return self
    }
    
    public func editable(_ flag: Bool = true) -> TrickleEditorView {
        self.config.editable = flag
        return self
    }
    
    public func fontSize(_ size: CGFloat) -> TrickleEditorView {
        self.config.baseFontSize = size
        return self
    }
    
    public func scrollable(_ flag: Bool = true) -> TrickleEditorView {
        self.config.scrollable = flag
        return self
    }
    
    public func onSend(_ onSend: @escaping ([TrickleData.Block]) -> Void) -> TrickleEditorView {
        self.config.onSend = onSend
        return self
    }
    
}



#if DEBUG
struct TrickleEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            TrickleEditorView(blocks: .constant(load("blocks.json")))
                .editable(true)
                .padding()
        }
        
    }
}
#endif

//            containerView {
                // contents
//                blockRowsView
//            }
//            .onChange(of: focusedRow) { newValue in
//                if newValue == -1 && blocks.count > 1 && blocks.last?.type == .richText && blocks.last?.elements?.first?.text == "" {
//                    blocks.removeLast()
//                }
//            }
