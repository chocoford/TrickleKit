//
//  EmbedWebView.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/4.
//

import SwiftUI
import WebKit
import TrickleKit


public struct EmbedBlockView: View {
    var block: TrickleData.Block

    public var body: some View {
        switch block.userDefinedValue {
            case .str(let iframeCode):
                EmbedWebView(iframeCode: iframeCode)
            case .embed(let value):
                EmbedWebView(iframeCode: value.src)
                    .frame(height: value.height != nil ? CGFloat(Double(value.height!) ?? 300) : nil)
            default:
                EmptyView()
        }
    }
}

fileprivate func getSrcFromIframe(_ iframeCode: String) -> String? {
    var urlStringMatch: String? = nil
//    if #available(macOS 13.0, iOS 16.0, *) {
//        let regex = /src="(?<url>[^"]*)/
//        urlStringMatch = String(iframeCode.firstMatch(of: regex)?.output.url ?? "")
//    } else {
        let range = NSRange(location: 0, length: iframeCode.utf16.count)
        let regex = try! NSRegularExpression(pattern: "src=\"(?<url>[^\"]*)")
        if let match = regex.matches(in: iframeCode, range: range).first {
            let matchRange = match.range(at: match.numberOfRanges - 1)
            if let substringRange = Range(matchRange, in: iframeCode) {
                urlStringMatch = String(iframeCode[substringRange])
            }
        }
//    }
    return urlStringMatch
}

public struct EmbedWebView {
    var iframeCode: String
}


#if os(macOS)
extension EmbedWebView: NSViewRepresentable {
    public func makeNSView(context: Context) -> WKWebView {
        let webView = context.coordinator.webView
        if let urlString = getSrcFromIframe(iframeCode),
           let url = URL(string: String(urlString)) {
            webView.load(URLRequest(url: url))
        }

        return webView
    }
    public func updateNSView(_ nsView: WKWebView, context: Context) {
        
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
#elseif os(iOS)
extension EmbedWebView: UIViewRepresentable {
    public func makeUIView(context: Context) -> WKWebView {
        let webView = context.coordinator.webView
        if let urlString = getSrcFromIframe(iframeCode),
           let url = URL(string: String(urlString)) {
            webView.load(URLRequest(url: url))
        }

        return webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
#endif


extension EmbedWebView {
    public final class Coordinator {
        let webView = WKWebView()
        
    }
}
