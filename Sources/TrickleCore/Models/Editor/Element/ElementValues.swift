//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/27.
//

import Foundation

// MARK: - Image
extension TrickleData.Element {
    public enum ImageElementValue: Codable, Hashable {
        case local(LocalImageData)
        case air(ImageData)
        
        public struct ImageData: Codable, Hashable {
            public let id: String
            public var url: String
            public var name: String
            public var uploaded: Bool?
            public var uploadFailed: Bool?
            public var naturalWidth: CGFloat?
            public var naturalHeight: CGFloat?
            
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
            
            public init(filename: String, localSrc: Data, naturalWidth: CGFloat, naturalHeight: CGFloat) {
                self.filename = filename
                self.localSrc = localSrc
                self.naturalWidth = naturalWidth
                self.naturalHeight = naturalHeight
            }
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
