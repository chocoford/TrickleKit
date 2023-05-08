//
//  SwiftUIView.swift
//  
//
//  Created by Chocoford on 2023/3/27.
//

import SwiftUI

struct TodosBlockView: View {
    var block: TrickleData.Block
    
    @State private var progress: CGFloat = 0.0
    
    var checkboxBlocks: [TrickleData.Block]? {
        guard let blocks = block.blocks, blocks.count >= 2 else {
            return nil
        }
        
        return blocks
    }
    
    var body: some View {
        if checkboxBlocks != nil {
            content
        } else {
            Text("Error Todos block.")
                .italic()
                .foregroundColor(.red)
        }
    }
    
    @ViewBuilder private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            TrickleEditorParser.parse(block.blocks?.prefix(2) ?? [])
            
            HStack {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)

                Text("\(Int(progress * 100))%")
            }
            
            if block.blocks?[2].type == .nest {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(block.blocks?[2].blocks ?? []) { block in
                        TrickleEditorParser.parse([block])
                    }
                }
            }

        }
        .onAppear {
            calProgress()
        }
        .onChange(of: checkboxBlocks) { _ in
            calProgress()
        }
    }
    
    func calProgress() {
        var checked = 0
        guard let total = checkboxBlocks?.count else { return }
        checkboxBlocks?.forEach({ checkbox in
            if case .checkbox(let val) = checkbox.userDefinedValue {
                if val.status == .checked {
                    checked += 1
                }
            }
        })
        
        progress = CGFloat(checked) / CGFloat(total)
    }
}


#if DEBUG

struct TodosBlockView_Previews: PreviewProvider {
    static var previews: some View {
        TodosBlockView(block: .init(type: .vote, blocks: [
            TrickleData.Block(type: .h3, elements: [
                TrickleData.Element(.text, text: "Todo title")
            ]),
            
            TrickleData.Block(type: .richText, elements: [
                TrickleData.Element(.text, text: "Todo description")
            ]),
            
            TrickleData.Block(type: .nest, blocks: [
                TrickleData.Block(type: .checkbox, elements: [
                    TrickleData.Element(.text, text: "Todo option 1")
                ]),
                TrickleData.Block(type: .checkbox, elements: [
                    TrickleData.Element(.text, text: "Todo option 2")
                ])
            ])
        ]))
        .frame(width: 720, height: nil)
        .previewLayout(.fixed(width: 720, height: 400))
    }
}

#endif
