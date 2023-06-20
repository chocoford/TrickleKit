//
//  EmbedWebView.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/4.
//

import SwiftUI
import WebKit
import TrickleCore
import ChocofordUI
import Shimmer

/// There are two size mismatch between `SwiftUI view`, `WKWebView` and the `twttr widgets`.
/// 1. Due to the fact that`twttr widgets` has a `maxWidth` of `550px`. We need to firstly make it full width, by scaling.
/// 2. The pixels in `WKWebView` is not equal to `SwiftUI view`'s. That means, we can not simply apply the width got from `clientWidth` to `SwiftUI views` directly
/// 3. Therefore, we must first get the first scale, held by `WKWebView`, represent the scale of `twttr widgets`. Then we can make it full-width.
/// 4. Secondly, we must get the scale of `WKWebView` pixel width to `SwiftUI view` width. Then we can calculate the actual height of `twttr widgets` in SwiftUI envrionment.
public struct EmbedBlockView: View {
    var block: TrickleData.Block

    @State var webWidth: CGFloat? = nil
    @State var webHeight: CGFloat? = nil
    @State private var isLoading = true
    
    public var body: some View {
        SingleAxisGeometryReader(axis: .horizontal) { width in
            let webViewHeight = (webHeight ?? 0) * (width / (webWidth ?? width))
            Group {
                switch block.userDefinedValue {
                    case .str(let iframeCode):
                        EmbedWebView(iframeCode: iframeCode, isLoading: $isLoading, webWidth: $webWidth, webHeight: $webHeight)
                            .frame(minHeight: 100)
                    case .embed(let value):
                        EmbedWebView(iframeCode: value.src, isLoading: $isLoading, webWidth: $webWidth, webHeight: $webHeight)
                            .frame(height: value.height != nil ? CGFloat(Double(value.height!) ?? 300) : min(10000, webViewHeight + 10))
                            .frame(minHeight: 100)
                    default:
                        EmptyView()
                }
            }
            .onTapGesture {}
            .overlay {
                if isLoading {
                    Rectangle()
                        .fill(.foreground)
                        .overlay(alignment: .bottomTrailing) {
                            Text("Trickle Embed")
                                .foregroundColor(.textColor)
                                .font(.system(size: 32, weight: .bold))
                        }
                        .shimmering()
                }
            }
            .animation(.easeInOut, value: webHeight)
        }
    }
}

fileprivate func getSrcFromIframe(_ iframeCode: String) -> String? {
    var urlStringMatch: String? = nil
//    if #available(macOS 13.0, iOS 16.0, *) {
//        let regex: Regex = try! Regex("src=\"(?<url>[^\"]*)") // /src="(?<url>[^"]*)/
//        urlStringMatch = String(iframeCode.firstMatch(of: regex)?.output.url ?? "")
//    } else {
    let range = NSRange(location: 0, length: iframeCode.utf16.count)
    let regex = try! NSRegularExpression(pattern: "src=\"(?<url>[^\"]*)")
    if let match = regex.matches(in: iframeCode, range: range).first {
        let matchRange = match.range(at: match.numberOfRanges - 1)
        if let substringRange = Range(matchRange, in: iframeCode) {
            urlStringMatch = String(iframeCode[substringRange])
        }
//        }
    }
    return urlStringMatch
}

public struct EmbedWebView {
    @Environment(\.openURL) var openURL
    var iframeCode: String
    @Binding var isLoading: Bool
    
    @Binding var webWidth: CGFloat?
    @Binding var webHeight: CGFloat?
    
    @State private var iframeWidth: CGFloat = 1

    var scale: CGFloat {
        guard let webWidth = webWidth else { return 1 }
        return webWidth / iframeWidth
    }

    func loadIframeJSCode(_ iframeCode: String) -> String {
        return """
const newBody = document.createElement('body');
newBody.innerHTML = '\(iframeCode)';
document.body = newBody;
document.body.classList.add('w-full', 'flex', 'justify-center', 'overflow-hidden', 'bg-transparent');
document.addEventListener('mousedown', (e) => e.stopPropagation());
document.addEventListener('touchstart', (e) => e.stopPropagation());
document.addEventListener('touchend', (e) => e.stopPropagation());
0
"""
    }
    
    func injectTailwindCode() -> String {
        return """
const styleScript = document.createElement('script');
styleScript.src = 'https://cdn.tailwindcss.com';
document.head.appendChild(styleScript)
styleScript.onload = () => {
    document.body.classList.add("1");
};
0
"""
    }
    
    var observeBodyHeightCode: String {
        """
const config = { attributes: true, childList: true, subtree: true };
const callback = (mutationList, observer) => {
     window.webkit.messageHandlers.heightCallback.postMessage(
            parseInt(document.querySelector('iframe')?.style.height.slice(0, -2)) || 100
     );
     window.webkit.messageHandlers.documentWidthCallback.postMessage(
            document.body.clientWidth
     );
     window.webkit.messageHandlers.iframeWidthCallback.postMessage(
            parseInt(document.querySelector('iframe')?.style.width.slice(0, -2)) || 550
     );
//     window.webkit.messageHandlers.debug.postMessage(
//           document.body.clientWidth || 100
//     );
};
const observer = new MutationObserver(callback);
observer.observe(document.body, config);
0
"""
    }
}


#if os(macOS)
extension EmbedWebView: NSViewRepresentable {
    public func makeNSView(context: Context) -> WKWebView {
        let webView = context.coordinator.webView
        loadEmbedContent(webView)
        return webView
    }
    public func updateNSView(_ webView: WKWebView, context: Context) {
        adjustTwttrHeight(webView)
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}
class EmbedWKWebView: WKWebView {
    override func scrollWheel(with theEvent: NSEvent) {
        nextResponder?.scrollWheel(with: theEvent)
        return
    }
}
#elseif os(iOS)
extension EmbedWebView: UIViewRepresentable {
    public func makeUIView(context: Context) -> WKWebView {
        let webView = context.coordinator.webView
        loadEmbedContent(webView)
        return webView
    }
    
    public func updateUIView(_ webView: WKWebView, context: Context) {
        adjustTwttrHeight(webView)
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}
class EmbedWKWebView: WKWebView {}
#endif


extension EmbedWebView {
    public final class Coordinator: NSObject {
        
        var parent: EmbedWebView
        
        init(parent: EmbedWebView) {
            self.parent = parent
            super.init()
            
            setupMessageHandlers()
            webView.uiDelegate = self
            webView.navigationDelegate = self
#if os(macOS)
            webView.setValue(false, forKey: "drawsBackground")
#elseif os(iOS)
            webView.isOpaque = false
            webView.scrollView.isScrollEnabled = false
            webView.scrollView.backgroundColor = .clear
            webView.backgroundColor = .clear
#endif
        }
        
        let webView = EmbedWKWebView()
    }
    
    
    func loadEmbedContent(_ webView: WKWebView) {
        // https://stackoverflow.com/a/74364030/9073579
        Task { @MainActor in
            do {
                try await webView.evaluateJavaScript(injectTailwindCode())
                if iframeCode.contains("twitter-tweet") {
                    await TwttrWidgetsJsManager.shared.load()
                    _ = try await webView.evaluateJavaScript(loadIframeJSCode(String(iframeCode.prefix(while: {$0 != "\n"}))))
                    if let script = TwttrWidgetsJsManager.shared.getScriptContent() {
                        try await webView.evaluateJavaScript(script + "\n0")
                        try await webView.evaluateJavaScript("twttr.widgets.load(); 0")
                        try await webView.evaluateJavaScript(observeBodyHeightCode)
                    }
                } else {
                    try await webView.evaluateJavaScript(loadIframeJSCode(iframeCode))
                }
                await Timer.wait(0.5)
                isLoading = false
            } catch {
                dump(error)
            }
        }
    }
    
    func adjustTwttrHeight(_ webView: WKWebView) {
        guard iframeCode.contains("twitter-tweet") else { return }
        
        let script = """
(() => {
    const twitterEl = document.querySelector('.twitter-tweet-rendered');
    if (twitterEl) {
        twitterEl.style.scale = \(scale);
        twitterEl.style.transformOrigin = 'top';
    }
})();
0
"""
        Task { @MainActor in
            do {
                try await webView.evaluateJavaScript(script)
            } catch {
                dump(error)
            }
        }
    }
}
extension EmbedWebView.Coordinator: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("didReceiveServerRedirectForProvisionalNavigation")
    }
}
extension EmbedWebView.Coordinator: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url, navigationAction.targetFrame == nil{
            parent.openURL(url)
        }
        return nil
    }
}

extension EmbedWebView.Coordinator: WKScriptMessageHandler {
    func setupMessageHandlers() {
        webView.configuration.userContentController.add(self, name: "heightCallback")
        webView.configuration.userContentController.add(self, name: "documentWidthCallback")
        webView.configuration.userContentController.add(self, name: "iframeWidthCallback")
        webView.configuration.userContentController.add(self, name: "debug")
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
            case "heightCallback":
                guard let height = message.body as? CGFloat else { return }
                parent.webHeight = height * parent.scale
                
            case "documentWidthCallback":
                guard let width = message.body as? CGFloat else { return }
                parent.webWidth = width
                
            case "iframeWidthCallback":
                guard let width = message.body as? CGFloat else { return }
                parent.iframeWidth = width

            case "debug":
                print("[debug]", message.body)
            default:
                print("Unhandled callback")
        }
    }
}

class TwttrWidgetsJsManager {
    static let shared = TwttrWidgetsJsManager()
    
    var content: String?
    
    func load() async {
        guard content == nil else { return }
        do {
            self.content = try await withCheckedThrowingContinuation { continuation in
                do {
                    let content = try String(contentsOf: URL(string: "https://platform.twitter.com/widgets.js")!)
                    continuation.resume(with: .success(content))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        } catch {
            print("Could not load widgets.js script")
        }
        
    }
        
    func getScriptContent() -> String? {
        return content
    }
}

#if DEBUG
struct EmbedBlockView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack {
                Rectangle().fill(.red).frame(height: 80)
                EmbedBlockView(block: .init(type: .embed, value: .embed(.init(src: "<blockquote class=\"twitter-tweet\"><p lang=\"zh\" dir=\"ltr\">现在做基于Embedding的文档问答已经不是什么新鲜事，但是这个视频还是值得一看，主要是他介绍了几种不同的生成问答结果的方式：<br>1. Stuff，我们熟知的把找到的文档块和问题一起扔给LLM总结<br>2.… <a href=\"https://t.co/Lt4kuqvHqs\">https://t.co/Lt4kuqvHqs</a> <a href=\"https://t.co/b9GfItmwjM\">pic.twitter.com/b9GfItmwjM</a></p>&mdash; 宝玉 (@dotey) <a href=\"https://twitter.com/dotey/status/1667790801420558342?ref_src=twsrc%5Etfw\">June 11, 2023</a></blockquote>\n<script async src=\"https://platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>\n")), blocks: []))
                    .border(.red)
                Rectangle().fill(.green).frame(height: 80)
            }
            .background(.black)
        }
    }
}
#endif
