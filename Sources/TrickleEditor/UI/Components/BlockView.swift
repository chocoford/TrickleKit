//
//  BlockView.swift
//  
//
//  Created by Chocoford on 2023/3/14.
//

import SwiftUI
import TrickleKit

#if os(macOS)
struct BlockView: NSViewRepresentable {
    typealias NSViewType = BlockTextView
    typealias Block = TrickleData.Block
    
    @EnvironmentObject var sharedTextStorage: SharedTextContentStorage
    
    @Binding var block: Block
    var isSelected: Bool
    
    var tag: Int
    
    public init(block: Binding<Block>, isSelected: Bool, tag: Int) {
        self._block = block
        self.isSelected = isSelected
        self.tag = tag
    }
    
    func makeNSView(context: Context) -> NSViewType {
        let textView = context.coordinator.textView
//        textView.replaceTextContainer(<#T##newContainer: NSTextContainer##NSTextContainer#>)
//        let textLayoutManager = NSTextLayoutManager()
//        let textContentStorage = NSTextContentStorage()
////        textContentStorage.delegate = self
//        textContentStorage.addTextLayoutManager(textLayoutManager)
//        let textContainer = NSTextContainer(size: NSSize(width: 200, height: 20))
//        textLayoutManager.textContainer = textContainer
//        textView.textLayoutManager = textLayoutManager

        // 设置其他 NSTextView 的相关属性
        return textView
    }
    
    func updateNSView(_ textView: NSViewType, context: Context) {
        // 更新其他 NSTextView 的相关属性
//        print("updateNSView")
    }
    
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        return coordinator
    }
}

// MARK: - Coordinator
extension BlockView {
    class Coordinator: NSObject, NSTextViewDelegate {
        lazy var textView = {
            let textView = BlockTextView()
            textView.delegate = self
            return textView
        }()
        
        override init() {
            super.init()
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(willSwitchToNSLayoutManager),
                                                   name: BlockTextView.willSwitchToNSLayoutManagerNotification,
                                                   object: nil)
        }
        
        func textView(_ textView: NSTextView, willChangeSelectionFromCharacterRange oldSelectedCharRange: NSRange, toCharacterRange newSelectedCharRange: NSRange) -> NSRange {
            print("willChangeSelectionFromCharacterRange \(oldSelectedCharRange) to \(newSelectedCharRange)")
            
            return newSelectedCharRange
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
//            print("textViewDidChangeSelection \(textView.selectedRange())")
        }
        
        @objc func willSwitchToNSLayoutManager(notification: Notification) {
            // 处理通知逻辑
            fatalError("willSwitchToNSLayoutManager")
        }
    }
}


extension BlockView {
    // 实现跨 TextView 的光标移动和框选功能
    func connectLayoutManager(_ layoutManager: NSLayoutManager, textContainers: inout [NSTextContainer], blockViews: [BlockView], index: Int) {
        let textContainer = NSTextContainer(size: CGSize(width: 0, height: CGFloat.greatestFiniteMagnitude))
        textContainers.append(textContainer)
        layoutManager.addTextContainer(textContainer)
//        let textView = context.coordinator.textView(index: index, textContainers: textContainers)
//        nsView.addSubview(textView)
        // 计算 TextView 的 frame 和 textContainer 的位置
        // 更新 layoutManager 和 textContainer 的相关属性
    }
}
#endif
