//
//  SwiftUIView.swift
//  
//
//  Created by Chocoford on 2023/3/27.
//

import SwiftUI
import TrickleCore

struct TodosBlockView: View {
    var block: TrickleBlock.TaskBlock
    
    @State private var progress: CGFloat = 0.0
    
    var checkboxBlocks: [TrickleBlock]? {
        let blocks = block.blocks
        guard blocks.count >= 2 else {
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
            TrickleEditor.renderBlocks(block.blocks.prefix(2))
            
            HStack {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)

                Text("\(Int(progress * 100))%")
            }
            
            if block.blocks[2].type == .nest {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(block.blocks[2].blocks ?? []) { block in
                        TrickleEditor.renderBlocks([block])
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
            if case .checkbox(let checkboxBlock) = checkbox {
                if checkboxBlock.userDefinedValue?.status == .checked {
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
        TodosBlockView(
            block: .init(
                blocks: [
                    .headline(.init(type: .h2, elements: .text("Todo title"))),
                    .text(.init(elements: .text("Todo description"))),
                    .nestable(
                        .init(type: .nest, blocks: [
                            .checkbox(.init(
                                elements: .text("Todo option 1"),
                                userDefinedValue: .unchecked
                            )),
                            .checkbox(.init(
                                elements: .text("Todo option 2"),
                                userDefinedValue: .unchecked
                            )),
                        ])
                    )
                ]
            )
        )
        .frame(width: 720, height: nil)
        .previewLayout(.fixed(width: 720, height: 400))
    }
}

#endif
