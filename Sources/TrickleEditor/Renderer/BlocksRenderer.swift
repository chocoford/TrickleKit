//
//  BlocksRenderer.swift
//  
//
//  Created by Chocoford on 2023/7/4.
//

import SwiftUI
import TrickleCore
import ChocofordEssentials

struct BlocksRenderer: View {
    var blocks: [TrickleBlock]
    var baseFontSize: CGFloat = 16
    
    init<S: Sequence>(blocks: S, baseFontSize: CGFloat) where S.Element == TrickleBlock {
        self.blocks = Array(blocks)
        self.baseFontSize = baseFontSize
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(blocks.enumerated()), id: \.1.id) { index, block in
                if let blocks = block.blocks, !blocks.isEmpty {
                    BlocksRenderer(blocks: blocks, baseFontSize: baseFontSize)
                        .blockModifier(block,
                                       baseFontSize: baseFontSize)
                } else {
                    let backupNumberedListPrefix: String = {
                        
//                        if case .list(let listBlock) = block {
//                            for i in 0..<index {
//                                let blockIndex = index - i
//                                if case .str(let value) = blocks[blockIndex].userDefinedValue,
//                                   let theIndex = Int(value.prefix(value.count - 1)) {
//                                    return "\(theIndex + i)."
//                                } else if blocks[blockIndex].type != .numberedList {
//                                    return "\(i)."
//                                }
//                            }
//                        }
                        return "1."
                    }()
                    
                    ElementsRenderer(elements: block.elements ?? [])
//                        .onAppear {
//                            print(block.type, block.elements)
//                        }
                        .blockModifier(block,
                                       baseFontSize: baseFontSize,
                                       backupNumberedListPrefix: backupNumberedListPrefix)
                }
            }
        }
    }
}

fileprivate extension View {
    @ViewBuilder
    func blockModifier(_ block: TrickleBlock,
                       baseFontSize: CGFloat = 16,
                       backupNumberedListPrefix: String = "1.") -> some View {
        switch block {
            case .headline(let headlienBlock):
                switch headlienBlock.type {
                    case .h1:
                        font(.system(size: baseFontSize * 2, weight: .bold))
                    case .h2:
                        font(.system(size: baseFontSize * 1.75, weight: .bold))
                    case .h3:
                        font(.system(size: baseFontSize * 1.5, weight: .semibold))
                    case .h4:
                        font(.system(size: baseFontSize * 1.375, weight: .semibold))
                    case .h5:
                        font(.system(size: baseFontSize * 1.25, weight: .medium))
                    case .h6:
                        font(.system(size: baseFontSize * 1.125, weight: .medium))
                    default:
                        self
                }
                
            case .code(let codeBlock):
                CodeBlockView(block: codeBlock)
                    
            case .list(let listBlock):
                switch listBlock.type {
                    case .list:
                        HStack(alignment: .top) {
                            Circle()
                                .frame(width: 4, height: 4)
                                .foregroundColor(.textColor)
                                .padding(.vertical, baseFontSize / 2)
                            self.font(.system(size: baseFontSize))
                        }
                    case .numberedList:
                        HStack(alignment: .top) {
                            if let value = listBlock.userDeinfedValue {
                                Text("\(value) ")
                                    .padding(.vertical, 2)
                            } else {
                                Text("\(backupNumberedListPrefix) ")
                                    .padding(.vertical, 2)
                            }
                            self.font(.system(size: baseFontSize))
                        }
                    default:
                        self
                }
                
            case .checkbox(let checklistBlock):
                HStack(alignment: .top) {
                    Toggle("", isOn: .constant(checklistBlock.userDefinedValue?.status == .checked))
                        .toggleStyle(.checkboxStyle)
                        .fixedSize()
                    self.font(.body)
                }
                
            case .divider(let dividerBlock):
                DividerBlockView(block: dividerBlock)

            case .gallery(let galleryBlock):
                GalleryBlockView(block: galleryBlock, focused: .constant(false))
                
            case .image:
                font(.title3)
                
            case .embed(let embedBlock):
                EmbedBlockView(block: embedBlock)
                
            case .webBookmark(let webBookmarkBlock):
                WebBookmarkBlockView(block: webBookmarkBlock)
                
            case .reference:
                font(.title3)
                
            case .file(let fileBlock):
                FileBlockView(block: fileBlock)
//                Text("[File] " + (fileBlock.userDefinedValue.name ?? ""))

            case .nestable:
                switch block.type {
                    case .quote:
                        QuoteBlockView(block: block)
                    default:
                        self.font(.body)
                }
                
            case .task(let taskBlock):
                TodosBlockView(block: taskBlock)
                
            case .vote(let voteBlock):
                VoteBlockView(block: voteBlock)
                
            case .progress(let progressBlock):
                Text("progressBlock..")
                
            case .text:
                font(.system(size: baseFontSize))
        }
    }
}

#if DEBUG
struct BlocksRenderer_Previews: PreviewProvider {
    static var previews: some View {
        TrickleEditor.renderBlocks(load("blocks.json") as [TrickleBlock])
    }
}
#endif
