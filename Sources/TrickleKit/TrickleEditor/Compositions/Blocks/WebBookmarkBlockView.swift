//
//  WebBookmarkBlockView.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/23.
//

import SwiftUI
import Shimmer

extension TrickleData.Block {
    public struct WebBookmarkBlockValue: Codable, Hashable {
        var url: URL
    }
}

public struct WebBookmarkBlockView: View {
    @Environment(\.openURL) var openURL
    var block: TrickleData.Block
    
    @State private var webInfo: [String : String] = [:]
    @State private var isHover: Bool = false
    public var body: some View {
        if case .webBookmark(let value) = block.userDefinedValue {
            content(value)
        } else {
            Text("Web Bookmark Block Error.")
                .italic()
                .foregroundColor(.red)
        }
    }
    
    @ViewBuilder private func content(_ value: TrickleData.Block.WebBookmarkBlockValue) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(webInfo["title"] ?? "")
                    .font(.title2)
                    .padding(.bottom, 4)
                Text(webInfo["description"] ?? "")
                    .font(.footnote)
            }
            
            AsyncImage(url: URL(string: webInfo["cover"] ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)

            } placeholder: {
                Rectangle()
                    .shimmering()
            }
        }
        .frame(height: 60)
        .padding()
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            isHover ?
            RoundedRectangle(cornerRadius: 8).fill(.indigo.opacity(0.2))
            :
            nil
        }
        .onTapGesture {
            openURL(value.url)
        }
        .onHover{ hover in
            withAnimation {
                isHover = hover
            }
        }
        .task {
            await fetchWebInfo(url: value.url)
        }
    }
}

extension WebBookmarkBlockView {
    func fetchWebInfo(url: URL) async {
        var meta: [String : String] = [:]
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let htmlString = String(data: data, encoding: .utf8) ?? ""

            func getStringFromRegex(_ parrtern: String, from component: String) throws -> [[String]] {
                let titleRegex = try NSRegularExpression(pattern: "content=\"([^\"]*)\"")
                let matches = titleRegex.matches(in: component, range: NSRange.init(location: 0, length: component.count))
                return matches.map { result in
                    return (1..<result.numberOfRanges).map {
                        guard let range = Range(result.range(at: $0), in: component) else { return "<Error encounted>"}
                        return String(component[range])
                    }
 
                }
            }
            
            let components = htmlString.components(separatedBy: "<meta")
            for component in components {
                // title
                if component.contains("property=\"og:title\"") {
                    try meta.updateValue(String(getStringFromRegex("content=\"([^\"]*)\"", from: component).first?.first ?? ""), forKey: "title")
                } else if component.contains("title>") {
                    meta.updateValue(String(component.suffix(component.count - 6)), forKey: "title")
                }
                
                // description
                if component.contains("property=\"og:description\"") {
                    try meta.updateValue(String(getStringFromRegex("content=\"([^\"]*)\"", from: component).first?.first ?? ""), forKey: "description")
                } else if component.contains("name=\"description\"") {
                    try meta.updateValue(String(getStringFromRegex("content=\"([^\"]*)\"", from: component).first?.first ?? ""), forKey: "description")
                }
                
                // cover
                if component.contains("property=\"og:image\"") {
                    try meta.updateValue(String(getStringFromRegex("content=\"([^\"]*)\"", from: component).first?.first ?? ""), forKey: "cover")
                } else if component.contains("itemprop=\"image\"") {
                    try meta.updateValue(String(getStringFromRegex("content=\"([^\"]*)\"", from: component).first?.first ?? ""), forKey: "cover")
                }
            }
            webInfo = meta
        } catch {
            
        }
    }
}
#if DEBUG
struct WebBookmarkBlockView_Previews: PreviewProvider {
    static var previews: some View {
        TrickleEditorView(blocks: .constant(load("blocks.json")))
    }
}
#endif
