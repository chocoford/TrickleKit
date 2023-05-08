//
//  FileBlockView.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/23.
//

import SwiftUI

extension TrickleData.Block {
    public struct FileBlockValue: Codable, Hashable {
        var url: URL
        var name: String
        var size: String
    }
}

public struct FileBlockView: View {
    var block: TrickleData.Block
    
    @State private var isHover = false
    
    public var body: some View {
        HStack {
            if case .file(let value) = block.userDefinedValue {
                content(value: value)
            } else {
                Text("File Block Error.")
                    .italic()
                    .foregroundColor(.red)
            }
        }
        .padding(4)
        .contentShape(RoundedRectangle(cornerRadius: 6))
        .background(RoundedRectangle(cornerRadius: 6).fill(isHover ? .gray.opacity(0.4) : .clear))
    }
    
    @ViewBuilder private func content(value: TrickleData.Block.FileBlockValue) -> some View {
        HStack {
            Image(systemName: "doc.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 16)
            
            Text(value.name)
                .fontWeight(.bold)
            Text(value.size)
                .foregroundColor(.gray)
            
            Spacer()
            
            Menu {
                Button {
                    
                } label: {
                    Label("Download", systemImage: "arrow.down.circle")
                }
            } label: {
                Image(systemName: "ellipsis")
            }
            .frame(width: 20)
            .menuIndicator(.hidden)
            .menuStyle(.borderlessButton)
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
        FileBlockView(block: .init(type: .file, value: .file(.init(url: URL(string: "https://devres.trickle.so/upload/users/18555201329823745/workspaces/76957788663709699/1680588753699/GoogleJ.jpeg")!,
                                                                   name: "GoogleJ.jpeg",
                                                                   size: "208KB")), blocks: []))
    }
}
#endif
