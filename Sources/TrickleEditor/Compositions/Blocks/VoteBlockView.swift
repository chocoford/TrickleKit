//
//  SwiftUIView.swift
//  
//
//  Created by Chocoford on 2023/3/26.
//

import SwiftUI
import TrickleCore

struct VoteBlockView: View {
    var block: TrickleBlock.VoteBlock
    
    var body: some View {
        VStack(alignment: .leading) {
            TrickleEditor.renderBlocks(block.blocks.prefix(2))
            
//            HStack {
//                ProgressView(value: 0.5)
//                    .progressViewStyle(.linear)
//
//                Text("50%")
//            }
            
            if block.blocks[2].type == .nest {
                ForEach(block.blocks[2].blocks ?? []) { block in
                    HStack {
                        TrickleEditor.renderBlocks([block])
                        Spacer(minLength: 0)
                    }
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8).stroke(.gray)
                    )
                        
                }
            }

        }
        
    }
}

#if DEBUG

struct VoteBlockView_Previews: PreviewProvider {
    static var previews: some View {
//        VoteBlockView(block: .init(type: .vote, blocks: [
//            TrickleBlock(type: .h3, elements: [
//                TrickleElement(.text, text: "Vote title")
//            ]),
//
//            TrickleBlock(type: .richText, elements: [
//                TrickleElement(.text, text: "Vote description")
//            ]),
//
//            TrickleBlock(type: .nest, blocks: [
//                TrickleBlock(type: .richText, elements: [
//                    TrickleElement(.text, text: "Vote option 1")
//                ]),
//                TrickleBlock(type: .richText, elements: [
//                    TrickleElement(.text, text: "Vote option 2")
//                ])
//            ])
//        ]))
        Text("")
        .frame(width: 720, height: nil)
        .previewLayout(.fixed(width: 720, height: 400))
    }
}

#endif
