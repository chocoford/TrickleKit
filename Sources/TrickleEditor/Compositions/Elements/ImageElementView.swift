//
//  ImageElementView.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/20.
//

import SwiftUI
import ChocofordUI
import CachedAsyncImage
import TrickleCore


struct ImageElementView: View {
    var element: TrickleElement.ImageElement
    var contentMode: SwiftUI.ContentMode = .fit
    
    var imageData: TrickleElement.ImageElementValue { element.value }
    
    @State private var error: Error? = nil
    
    var body: some View {
        content(imageData: imageData)
    }
    
    @ViewBuilder private func content(imageData: TrickleElement.ImageElementValue) -> some View {
        switch imageData {
            case .local(let data):
                Image(nsImage: data.image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            case .air(let data):
                if let urlString = data.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                   let url = URL(string: urlString),
                   error == nil {
                    let urls = extractImageURLs(url)
                    ImageViewer(url: urls.url) {
                        webImage(urls.previewURL)
                    }
                } else {
                    errorView(url: data.url)
                }
        }
        
        
    }
    
    @ViewBuilder
    private func webImage(_ url: URL) -> some View {
#if os(macOS)
        let isAnimating: Binding<Bool> = .constant(false)
#elseif os(iOS)
        let isAnimating: Binding<Bool> = .constant(true)
#endif
        CachedAsyncImage(url: url) { image in
            image.resizable()
                .aspectRatio(contentMode: contentMode)
            
        } placeholder: {
            Rectangle()
                .shimmering()
        }
//        .onFailure { error in
//            self.error = error
//        }
#if os(macOS)
            .overlay(alignment: .bottomTrailing) {
                if url.pathExtension == "gif" {
                    Text("GIF")
                        .font(.headline)
                        .padding()
                        .background(.ultraThickMaterial)
                }
            }
#endif
    }
//
//    @ViewBuilder
//    private func kfImage(_ url: URL) -> some View {
//#if os(macOS)
//        AnimatedImage(url: url)
//#elseif os(iOS)
//        KFImage(url: url)
//            .cacheMemoryOnly()
//            .resizable()
//            .placeholder {
//                Rectangle()
//                    .shimmering()
//            }
//            .onFailure { error in
//                self.error = error
//            }
//            .aspectRatio(contentMode: contentMode)
//#endif
//
//    }
    
    @ViewBuilder
    private func asyncImage(_ url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                case .empty:
                    Rectangle()
                        .shimmering()
                case .failure(let error):
                    errorView(url: url.absoluteString)
                @unknown default:
                    errorView(url: url.absoluteString)
            }
        }
    }
    
    @ViewBuilder private func errorView(url: String) -> some View {
        VStack {
            Text(url)
            Text("Image load failed: \(error.debugDescription)")
                .italic()
        }
        .foregroundColor(.red)
    }
}

extension ImageElementView {
    struct URLs {
        let url: URL
        let previewURL: URL
    }
    func extractImageURLs(_ baseURL: URL) -> URLs {
        var url = baseURL
        var previewURL = baseURL
        if url.pathExtension != "gif" {
            if #available(macOS 13.0, iOS 16.0, *) {
                previewURL = url.appending(queryItems: [.init(name: "x-oss-process", value: "image/format,jpg/auto-orient,1/resize,w_500/")])
                url = url.appending(queryItems: [.init(name: "x-oss-process", value: "image/format,jpg/auto-orient,1/resize,w_1440/")])
            } else {
                previewURL = URL(string: url.absoluteString.appending("?x-oss-process=image/format,jpg/auto-orient,1/resize,w_500/")) ?? baseURL
                url = URL(string: url.absoluteString.appending("?x-oss-process=image/format,jpg/auto-orient,1/resize,w_1440/")) ?? baseURL
            }
        }
        
        return URLs(url: url, previewURL: previewURL)
    }
}


#if DEBUG
struct ImageElementView_Previews: PreviewProvider {
    static var previews: some View {
        ImageElementView(
            element:
                    .init(value: .air(.init(url: "https://devres.trickle.so/upload/users/50356547938680833/workspaces/76957788663709699/1675312457501/%E6%88%AA%E5%B1%8F2023-02-02%2012.32.26.png",
                                            name: "image")))
        )
        .frame(width: 600)
    }
}
#endif
