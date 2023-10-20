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
class TrickleGalleryAttachment: NSTextAttachment {
    weak var textLayoutManager: NSTextLayoutManager? = nil

//    init(image: NSImage) {
//        image
//        super.init(data: contentData, ofType: uti)
//    }
    
    override init(data contentData: Data?, ofType uti: String?) {
        super.init(data: contentData, ofType: uti)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setup() {
//        print("setup")
//        self.attachmentCell = GalleryImageAttchmentCell()
//        self.attachmentCell?.attachment = self
    }
    
    
//    override func viewProvider(for parentView: NSView?, location: NSTextLocation, textContainer: NSTextContainer?) -> NSTextAttachmentViewProvider? {
//        let viewProvider = TrickleGalleryAttachmentViewProvider(textAttachment: self,
//                                                                parentView: parentView,
//                                                                textLayoutManager: textContainer?.textLayoutManager,
//                                                                location: location)
//        viewProvider.tracksTextAttachmentViewBounds = true
//        return viewProvider
//    }
    
//    override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> NSImage? {
//        print("imageBounds", imageBounds)
//        return self.image
//    }

//    override func attachmentBounds(for textContainer: NSTextContainer?,
//                                   proposedLineFragment lineFrag: CGRect,
//                                   glyphPosition position: CGPoint,
//                                   characterIndex charIndex: Int) -> CGRect {
//        print("attachmentBounds", lineFrag)
//        return lineFrag
//    }
    
//    override func image(for bounds: CGRect,
//                        attributes: [NSAttributedString.Key : Any] = [:],
//                        location: NSTextLocation,
//                        textContainer: NSTextContainer?) -> NSImage? {
//        print("image for \(bounds), attributes: \(attributes), textContainer's size: \(textContainer?.containerSize)")
//        guard let image = self.image else { return nil }
//    }
    
    override func attachmentBounds(for attributes: [NSAttributedString.Key : Any],
                                   location: NSTextLocation,
                                   textContainer: NSTextContainer?,
                                   proposedLineFragment: CGRect,
                                   position: CGPoint) -> CGRect {
        guard let image = image, let textContainer = textContainer else { return proposedLineFragment }
        let imageSize = image.size
        let containerWidth = textContainer.size.width - 12
        let bounds = CGRect(origin: .zero,
                            size: .init(width: containerWidth, height: containerWidth / imageSize.width * imageSize.height))
        return bounds
    }
    
}

//extension TrickleGalleryAttachment: NSSharingServicePickerDelegate {
//    func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, sharingServicesForItems items: [Any], proposedSharingServices proposedServices: [NSSharingService]) -> [NSSharingService] {
//
//    }
//}
#if os(macOS)
class TrickleGalleryAttachmentViewProvider: NSTextAttachmentViewProvider {
    override func loadView() {
        let attachmentView = GalleryAttachmentView()
        attachmentView.textAttachment = textAttachment as? TrickleGalleryAttachment
        view = attachmentView
    }
}

class GalleryImageAttchmentCell: NSTextAttachmentCell {
    weak var textLayoutManager: NSTextLayoutManager? = nil
    
//    override nonisolated func cellSize() -> NSSize {
//        let imageSize = self.image?.size ?? .zero
//        let containerWidth = (textLayoutManager?.textContainer?.size.width ?? .zero) - 12
//        let result: NSSize = .init(width: containerWidth, height: containerWidth / imageSize.width * imageSize.height)
//        return result
//    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        print("drawing GalleryImageAttchmentCell")
        NSColor.blue.setFill()
        cellFrame.fill()
    }
    
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        print("drawingRect forBounds \(rect)")
        return rect
    }
    
    override func highlight(_ flag: Bool, withFrame cellFrame: NSRect, in controlView: NSView?) {
        print("highlight with frame", cellFrame)
    }
    
    override func trackMouse(with theEvent: NSEvent, in cellFrame: NSRect, of controlView: NSView?, untilMouseUp flag: Bool) -> Bool {
        print("trackMouse(with \(theEvent), in \(cellFrame), of \(controlView), untilMouseUp \(flag))")
        return super.trackMouse(with: theEvent, in: cellFrame, of: controlView, untilMouseUp: flag)
    }
}

class GalleryAttachmentView: NSView {
    var textAttachment: TrickleGalleryAttachment? = nil

    var xPadding: CGFloat { return 3 }
    var yPadding: CGFloat { return 1 }
    
    override var intrinsicContentSize: NSSize {
        let imageSize = textAttachment?.image?.size ?? .zero
        let containerWidth = (textAttachment?.textLayoutManager?.textContainer?.size.width ?? .zero) - 12
        let result: NSSize = .init(width: containerWidth, height: containerWidth / imageSize.width * imageSize.height)
        return result
    }
    
    var backgroundColor: NSColor {
        return .systemGray
    }
    
    override func draw(_ dirtyRect: NSRect) {
        print("draw in \(dirtyRect)")
//        backgroundColor.set()
//        bounds.fill()
//        textAttachment?.image?.draw(in: .init(x: xPadding,
//                                              y: yPadding,
//                                              width: dirtyRect.width - xPadding,
//                                              height: dirtyRect.height - yPadding))
        textAttachment?.image?.draw(in: dirtyRect)
    }
}
#endif
