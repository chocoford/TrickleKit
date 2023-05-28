//
//  QuoteBlockView.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/23.
//

import SwiftUI
import TrickleCore
import ChocofordEssentials

struct QuoteBlockView: View {
    var block: TrickleData.Block
    var body: some View {
        VStack(spacing: 0) {
            TrickleEditorParser.parse(block.blocks ?? [])
                
//            ForEach(block.blocks ?? []) { block in
//
//            }
                .padding(8)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor)
                        RoundedRectangle(cornerRadius: 8).fill(Color.accentColor.opacity(0.2))
                            .border(.leading, width: 4, color: Color.accentColor)
                    }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                )
        }
    }
}

#if DEBUG
struct QuoteBlockView_Previews: PreviewProvider {
    static var previews: some View {
        TrickleEditorView(blocks: .constant(load("blocks.json")))
    }
}
#endif
