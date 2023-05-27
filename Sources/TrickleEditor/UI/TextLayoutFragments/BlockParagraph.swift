//
//  File.swift
//  
//
//  Created by Chocoford on 2023/3/17.
//

import Foundation
#if os(macOS)
import AppKit

class BlockParagraph: NSTextParagraph {
    override var childElements: [NSTextElement] {
        [NSTextParagraph(attributedString: attributedString)]
    }
}
#endif
