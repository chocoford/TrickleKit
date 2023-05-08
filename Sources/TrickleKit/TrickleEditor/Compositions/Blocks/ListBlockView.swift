//
//  ListBlockView.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/23.
//

import SwiftUI

extension TrickleData.Block {

}

struct ListBlockView: View {
    @EnvironmentObject var config: TrickleEditorConfig

    var block: TrickleData.Block
    @Binding var text: AttributedString
    var editable: Bool = true
    
    @Binding var focused: Bool
    var onKeydown: ((KeyboardEvent) -> Void)?
    
    var body: some View {
        content()
    }
    
    @ViewBuilder private func content() -> some View {
        HStack(spacing: 0) {
            Group {
                switch block.type {
                    case .list:
                        Text("·")
                    case .numberedList:
                        if case .str(let val) = block.userDefinedValue {
                            Text(val)
                        } else {
                            EmptyView()
                        }
                    default:
                        EmptyView()
                }
            }.frame(minWidth: 10)
            TrickleEditorBlock(text: $text, font: .systemFont(ofSize: config.baseFontSize), editable: editable, focused: $focused, onKeydown: onKeydown)
        }
    }
}

#if DEBUG
struct ListBlockView_Previews: PreviewProvider {
    static var previews: some View {
        TrickleEditorView(blocks: .constant(load("blocks.json")))
        .padding()
    }
}

#endif
