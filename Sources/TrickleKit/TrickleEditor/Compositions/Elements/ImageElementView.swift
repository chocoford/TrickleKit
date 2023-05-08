//
//  ImageElementView.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/20.
//

import SwiftUI
import ChocofordUI
import SDWebImageSwiftUI

extension TrickleData.Element {
    public enum ImageElementValue: Codable, Hashable {
        case local(LocalImageData)
        case air(ImageData)
        
        public struct ImageData: Codable, Hashable {
            let id: String
            var url: String
            var name: String
            var uploaded: Bool?
            var uploadFailed: Bool?
            var naturalWidth: CGFloat?
            var naturalHeight: CGFloat?
            
            public init(id: String = UUID().uuidString, url: String, name: String, uploaded: Bool = false, uploadFailed: Bool = false) {
                self.id = id
                self.url = url
                self.name = name
                self.uploaded = uploaded
                self.uploadFailed = uploadFailed
            }
        }
        
        public struct LocalImageData: Codable, Hashable {
            public var filename: String
            public var localSrc: Data
            public var naturalWidth: CGFloat
            public var naturalHeight: CGFloat
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            if let v = try? container.decode(ImageData.self) {
                self = .air(v)
                return
            }
            if let v = try? container.decode(LocalImageData.self) {
                self = .local(v)
                return
            }
            
            throw DecodingError.typeMismatch(
                ImageElementValue.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "[ImageElementValue] Type is not matched", underlyingError: nil))
        }
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
                case .air(let value):
                    try container.encode(value)
                case .local(let value):
                    try container.encode(value)
            }
        }
    }
    
  
}

struct ImageElementView: View {
    var element: TrickleData.Element
    var contentMode: ContentMode = .fit
    
    var imageData: TrickleData.Element.ImageElementValue? {
        if case .galleryImageValue(let value) = element.value {
            return value
        } else if case .str(let src) = element.value {
            return TrickleData.Element.ImageElementValue.air(.init(url: src, name: "untitled"))
        }
        return nil
    }
    
    @State private var error: Error? = nil
    
    var body: some View {
        if let imageData = imageData {
            content(imageData: imageData)
        } else {
            Text("Image load failed: invalid image data.")
                .italic()
                .foregroundColor(.red)
                .padding()
                .background(.ultraThickMaterial)
        }
    }
    
    @ViewBuilder private func content(imageData: TrickleData.Element.ImageElementValue) -> some View {
        switch imageData {
            case .local(let data):
                if let image = Image(data: data.localSrc) {
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                }
            case .air(let data):
                if let urlString = data.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                   let url = URL(string: urlString),
                   error == nil {
                    let urls = extractImageURLs(url)
                    ImageViewer(url: urls.url) {
                        WebImage(url: urls.previewURL)
                            .resizable()
                            .placeholder {
                                Rectangle()
                                    .shimmering()
                            }
                            .onFailure { error in
                                self.error = error
                            }
                            .aspectRatio(contentMode: contentMode)
                    }
                } else {
                    errorView(url: data.url)
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
        ImageElementView(element: .init(.image, value: .galleryImageValue(.air(.init(url: "https://devres.trickle.so/upload/users/50356547938680833/workspaces/76957788663709699/1675312457501/%E6%88%AA%E5%B1%8F2023-02-02%2012.32.26.png", name: "image"))))
        )
        .frame(width: 600)
    }
}
#endif
