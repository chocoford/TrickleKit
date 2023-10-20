//
//  File.swift
//  
//
//  Created by Chocoford on 2023/6/20.
//

import Foundation
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import TrickleCore
import OSLog

//class MyTextContainer: NSTextContainer {
//
//    override var textLayoutManager: NSTextLayoutManager? {
//
//    }
//}

public class TrickleEditorStore: NSObject, ObservableObject {
#if os(iOS)
    public typealias Image = UIImage
    public typealias Color = UIColor
#elseif os(macOS)
    public typealias Image = NSImage
    public typealias Color = NSColor
#endif
    private(set) var textContentStorage: NSTextContentStorage
    private(set) var textLayoutManager: NSTextLayoutManager = .init()
    private(set) var textContainer: NSTextContainer = .init()
    
    public var delegate: TrickleEditorStoreDelegate? = nil
    
    public var blocks: [TrickleBlock] {
        set(val) {
            textContentStorage.textStorage = .init(attributedString: NSAttributedString(val.toAttributedString()))
        }
        
        get {
            textContentStorage.attributedString?.toBlocks() ?? .default
        }
    }
    
    private var logger: Logger = .init(subsystem: "SwiftyTrickle", category: "TrickleEditorStore")
    
    public init(textContentStorage: NSTextContentStorage = .init()) {
        self.textContentStorage = textContentStorage
        super.init()
        setup()
    }
    
    func setup() {
        self.textContainer.widthTracksTextView = true
        self.textContainer.heightTracksTextView = false
        self.textLayoutManager.textContainer = self.textContainer
        self.textContentStorage.addTextLayoutManager(self.textLayoutManager)
        self.textContentStorage.primaryTextLayoutManager = self.textLayoutManager
        
        
        self.textLayoutManager.delegate = self
    }
    
    public func insertImages(_ images: [Image]) {
        logger.info("inserting  \(images.count) images...")
        for image in images {
            let attachment = TrickleGalleryAttachment()
            attachment.image = image
            attachment.textLayoutManager = self.textLayoutManager
            
            self.textContentStorage.performEditingTransaction {
                let galleryAttributedString = NSMutableAttributedString(attachment: attachment)
#if os(macOS)
                galleryAttributedString.addAttribute(.foregroundColor, value: Color.textColor,
                                                     range: .init(location: 0, length: galleryAttributedString.length))
#endif
                self.textContentStorage.textStorage?.append(galleryAttributedString)
            }
        }
        delegate?.textContentStorageDidChanged()
        
    }
    
#if os(macOS)
    public func testInsertImage() {
//        let panel = NSOpenPanel()
//        if panel.runModal() == .OK {
//            if let url = panel.url {
//                let attachment = url.textAttachment
//                
//                let imageSize = NSImage(contentsOf: url)?.size ?? .zero
//                let containerWidth = (self.textContainer.size.width) - 12
//                let result: CGRect = .init(origin: .zero,
//                                           size: .init(width: containerWidth, height: containerWidth / imageSize.width * imageSize.height))
////                attachment.bounds = result
//                self.textContentStorage.textStorage?.append(.init(attachment: attachment))
//                delegate?.textContentStorageDidChanged()
//            }
//        }
    }
#endif
    
    public func insertAttachments() {
        
    }
}


extension TrickleEditorStore: NSTextLayoutManagerDelegate {
    public func textLayoutManager(_ textLayoutManager: NSTextLayoutManager,
                                  textLayoutFragmentFor location: NSTextLocation,
                                  in textElement: NSTextElement) -> NSTextLayoutFragment {
        let fallbackFragment = NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
        let index = textLayoutManager.offset(from: textLayoutManager.documentRange.location, to: location)
        guard self.textContentStorage.textStorage?.length ?? 0 > 0 else { return fallbackFragment }
        if let blockType = self.textContentStorage.textStorage?.attribute(.blockType, at: index, effectiveRange: nil) as? TrickleCore.TrickleBlock.BlockType {
            switch blockType {
                case .gallery:
                    let galleryFragment = GalleryLayoutFragment(textElement: textElement, range: textElement.elementRange)
                    return galleryFragment
                default:
                    break
            }
        }
        return fallbackFragment
    }
}


public protocol TrickleEditorStoreDelegate {
    func textContentStorageDidChanged()
}
