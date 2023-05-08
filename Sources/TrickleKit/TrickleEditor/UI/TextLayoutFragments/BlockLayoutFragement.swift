//
//  File.swift
//  
//
//  Created by Chocoford on 2023/3/17.
//

#if os(macOS)
import AppKit

class BlockLayoutFragement: NSTextLayoutFragment {
    private var _textLineFragments: [NSTextLineFragment] = []
    
    override var textLineFragments: [NSTextLineFragment] {
        return super.textLineFragments
//        guard let paragraph = self.textElement as? NSTextParagraph else { return _textLineFragments }
//
//        _textLineFragments = [
//            NSTextLineFragment(attributedString: paragraph.attributedString, range: .init(location: 0, length: paragraph.attributedString.length))
//        ]
        
//        return _textLineFragments
    }
}
#endif
