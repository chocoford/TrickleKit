//
//  SwiftUIView.swift
//  
//
//  Created by Chocoford on 2023/3/26.
//

import SwiftUI

struct VoteBlockView: View {
    var block: TrickleData.Block
    
    var body: some View {
        VStack(alignment: .leading) {
            TrickleEditorParser.parse(block.blocks?.prefix(2) ?? [])
            
//            HStack {
//                ProgressView(value: 0.5)
//                    .progressViewStyle(.linear)
//
//                Text("50%")
//            }
            
            if block.blocks?[2].type == .nest {
                ForEach(block.blocks?[2].blocks ?? []) { block in
                    HStack {
                        TrickleEditorParser.parse([block])
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
        VoteBlockView(block: .init(type: .vote, blocks: [
            TrickleData.Block(type: .h3, elements: [
                TrickleData.Element(.text, text: "Vote title")
            ]),
            
            TrickleData.Block(type: .richText, elements: [
                TrickleData.Element(.text, text: "Vote description")
            ]),
            
            TrickleData.Block(type: .nest, blocks: [
                TrickleData.Block(type: .richText, elements: [
                    TrickleData.Element(.text, text: "Vote option 1")
                ]),
                TrickleData.Block(type: .richText, elements: [
                    TrickleData.Element(.text, text: "Vote option 2")
                ])
            ])
        ]))
        .frame(width: 720, height: nil)
        .previewLayout(.fixed(width: 720, height: 400))
    }
}

#endif
