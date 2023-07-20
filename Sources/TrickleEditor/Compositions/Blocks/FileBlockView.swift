//
//  FileBlockView.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/23.
//

import SwiftUI
import TrickleCore
import SFSymbolEnum

public struct FileBlockView: View {
    var block: TrickleBlock.FileBlock
    
    @State private var isHover = false
    
    public var body: some View {
        HStack {
            content(value: block.userDefinedValue)
        }
        .padding(4)
        .contentShape(RoundedRectangle(cornerRadius: 6))
        .background(RoundedRectangle(cornerRadius: 6).fill(isHover ? .gray.opacity(0.4) : .clear))
    }
    
    @ViewBuilder private func content(value: TrickleBlock.FileBlockValue) -> some View {
        HStack {
            Image(systemName: .docFill)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 16)
            
//            Text(value.name ?? "Untitled file")
//                .fontWeight(.bold)
//            Text(value.size ?? "")
//                .foregroundColor(.gray)
            
            Spacer()
//
//            Menu {
//                Button {
//
//                } label: {
//                    Label("Download", systemImage: "arrow.down.circle")
//                }
//            } label: {
//                Image(systemName: "ellipsis")
//            }
//            .frame(width: 20)
//            .menuIndicator(.hidden)
//            .menuStyle(.borderlessButton)
        }
        .onHover { hover in
            withAnimation {
                isHover = hover
            }
        }
    }
}
#if DEBUG
struct FileBlockView_Previews: PreviewProvider {
    static var previews: some View {
        FileBlockView(block: .init(userDefinedValue:
                .init(url: URL(string: "https://devres.trickle.so/upload/users/18555201329823745/workspaces/76957788663709699/1680588753699/GoogleJ.jpeg")!,
                      name: "GoogleJ.jpeg",
                      size: "208KB"))
        )
    }
}
#endif
