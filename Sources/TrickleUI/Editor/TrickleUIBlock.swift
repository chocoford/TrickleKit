//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/28.
//

import Foundation
import TrickleCore

extension [TrickleData.Block] {
    public func toAttributedString(baseFontSize: CGFloat = 16) -> AttributedString {
        var attributedString = AttributedString()
        var lastNumberedListIndex = 1
        for block in self {
            var blockString = AttributedString()
            
            for element in block.elements ?? [] {
                switch element.type {
                    case .text:
                        blockString.append(AttributedString(stringLiteral: element.text))
                        
                    case .image:
//                        AttributedString().attachment = .init(data: <#T##Data?#>, ofType: <#T##String?#>)
//                        blockString.append()
                        break
                        
                    default:
                        blockString.append(AttributedString(stringLiteral: element.text))
                }
            }
            
            blockString.font = .systemFont(ofSize: baseFontSize, weight: .regular)
            switch block.type {
                case .h1:
                    blockString.font = .systemFont(ofSize: baseFontSize * 2, weight: .bold)
                case .h2:
                    blockString.font = .systemFont(ofSize: baseFontSize * 1.75, weight: .bold)
                case .h3:
                    blockString.font = .systemFont(ofSize: baseFontSize * 1.5, weight: .semibold)
                case .h4:
                    blockString.font = .systemFont(ofSize: baseFontSize * 1.375, weight: .semibold)
                case .h5:
                    blockString.font = .systemFont(ofSize: baseFontSize * 1.25, weight: .medium)
                case .h6:
                    blockString.font = .systemFont(ofSize: baseFontSize * 1.125, weight: .medium)
                    
                    
                    
                case .list:
                    blockString = AttributedString(stringLiteral: "•  ") + blockString
//                    blockString.paragraphStyle.
                    
                case .numberedList:
                    if case .str(let index) = block.userDefinedValue {
                        blockString = AttributedString(stringLiteral: "\(index) ") + blockString
                        lastNumberedListIndex = Int(index.prefix(index.count - 1)) ?? 1
                    } else if block.isFirst == false {
                        blockString = AttributedString(stringLiteral: "\(lastNumberedListIndex + 1). ") + blockString
                        lastNumberedListIndex += 1
                    }
                    
                default:
                    blockString.font = .systemFont(ofSize: baseFontSize, weight: .regular)

            }
            
            blockString.append(AttributedString(stringLiteral: "\n"))
            attributedString.append(blockString)
            
            
        }
        
        return attributedString
    }
}
