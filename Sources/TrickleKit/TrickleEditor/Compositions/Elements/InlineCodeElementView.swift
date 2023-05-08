//
//  SwiftUIView.swift
//  
//
//  Created by Chocoford on 2023/3/20.
//

import SwiftUI

//struct InlineCodeElementView: View {
//
//}

#if os(macOS)
class AttachmentView: NSView {
    var textAttachment: InlineCodeAttachment? = nil
    private var isMouseDown: Bool = false
    
    override var intrinsicContentSize: NSSize {
        var result: NSSize = .init(width: 60.0, height: labelText.size().height)
        result.width += xPadding * 2
        result.height += yPadding * 2
        return result
    }
    
    var xPadding: CGFloat { return 3 }
    var yPadding: CGFloat { return 1 }
    var cornerRadius: CGFloat { return 3 }

    var fillColor: NSColor {
        .systemRed
    }

    var labelText: NSAttributedString {
        let string = textAttachment?.contents != nil ? (String(data: textAttachment!.contents!, encoding: .utf8) ?? "") : ""
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.textColor
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }

    override func draw(_ rect: CGRect) {
        NSColor.clear.set()
        bounds.fill()
        NSColor.systemIndigo.set()
        NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius).fill()
        NSColor.systemRed.set()
        NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius).stroke()
        let labelSize = labelText.size()
        labelText.draw(at: NSPoint(x: bounds.origin.x + (bounds.size.width - labelSize.width) / 2.0, y: bounds.origin.y + yPadding))
    }
}

class AttachmentViewProvider: NSTextAttachmentViewProvider {
    override func loadView() {
        let attachmentView = AttachmentView()
        attachmentView.textAttachment = textAttachment as? InlineCodeAttachment
        view = attachmentView
    }
}

public class InlineCodeAttachment: NSTextAttachment {
    public override func viewProvider(for parentView: NSView?, location: NSTextLocation, textContainer: NSTextContainer?) -> NSTextAttachmentViewProvider? {
        let viewProvider = AttachmentViewProvider(textAttachment: self, parentView: parentView,
                                                  textLayoutManager: textContainer?.textLayoutManager,
                                                  location: location)
        viewProvider.tracksTextAttachmentViewBounds = true
        return viewProvider
    }
}

public class InlineCodeAttributedString: NSMutableAttributedString {
    
    public override func draw(in rect: NSRect) {
        super.draw(in: rect)
//        NSColor.systemRed.set()
//        NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4).stroke()
    }
}
#endif

#if DEBUG
//struct InlineCodeElementView_Previews: PreviewProvider {
//    static var previews: some View {
//        InlineCodeElementView()
//    }
//}
#endif
