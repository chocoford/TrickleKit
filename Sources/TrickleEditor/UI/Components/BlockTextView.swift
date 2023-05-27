//
//  File.swift
//  
//
//  Created by Chocoford on 2023/3/15.
//

import SwiftUI

#if os(macOS)
import AppKit

class BlockTextView: NSTextView {
    var isSelected: Bool = false
    
    var highlightRects: [NSRect] = [] {
        didSet {
            needsDisplay = true
        }
    }
    
    var onSelectionRangeChanged: ((_ range: NSRange) -> Void)? = nil
    

    override func mouseDown(with event: NSEvent) {
        // Set the initial selection range
        let initialSelection = self.selectedRange
        
        // Call the parent mouseDown method
        super.mouseDown(with: event)
        
        // Will be called after mouseup if it is a range selection.
        
        // Check if the selection range has changed
        if initialSelection != self.selectedRange {
            // Notify the parent BlockView that the selection range has changed
            if let onSelectionRangeChanged = onSelectionRangeChanged {
                onSelectionRangeChanged(self.selectedRange)
            }
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if !highlightRects.isEmpty {
            highlightRects.forEach { rect in
                let path = NSBezierPath(rect: rect)
                NSColor.red.setFill()
                path.fill()
                
            }
            print("did draw hightligt rects")
        }
    }

}

private extension BlockTextView {
    private func updateSelectionHighlights() {
        if textLayoutManager?.textSelections.isEmpty == false {
            for textSelection in textLayoutManager!.textSelections {
                for textRange in textSelection.textRanges {
                    textLayoutManager!.enumerateTextSegments(in: textRange,
                                                             type: .highlight,
                                                             options: []) {(textSegmentRange, textSegmentFrame, baselinePosition, textContainer) in
                        highlightRects.append(textSegmentFrame)
                        return true // keep going
                    }
                }
            }
        } else {
            highlightRects.removeAll()
        }
    }
}

#elseif os(iOS)

#endif


struct DragHandleView: View {
    var body: some View {
        Image(systemName: "plus")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 20)
    }
}

struct ToolbarView: View {
    var body: some View {
        HStack {
            Button {
                
            } label: {
                Image(systemName: "bold")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 10)
                    .padding(6)
            }
            
            Button {
                
            } label: {
                Image(systemName: "italic")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 10)
                    .padding(6)
            }
            
        }
        
        .buttonStyle(.borderedProminent)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(width: 100, height: 40)
        #if os(macOS)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(Color(nsColor: .systemIndigo))
                .shadow(color: Color(nsColor: .shadowColor), radius: 4)
        )
        #endif
    }
}

