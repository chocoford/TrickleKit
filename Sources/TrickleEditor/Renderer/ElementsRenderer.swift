//
//  ElementsRenderer.swift
//  
//
//  Created by Chocoford on 2023/7/4.
//

import SwiftUI
import TrickleCore
import TrickleUI

struct ElementsRenderer: View {
    var elements: [TrickleElement]
    
    var body: some View {
        Array(elements.enumerated()).map { (i, element) in
            elementText(element)
                .elementModifier(element)
        }
        .reduce(Text(""), +)
    }
    
    func elementText(_ element: TrickleElement) -> Text {
        if let elements = element.elements, !elements.isEmpty {
            return Array(elements.enumerated()).map { (i, element) in
                elementText(element)
                    .elementModifier(element)
            }.reduce(Text(""), +)
        } else {
            return Text(element.text)
                .elementModifier(element)
        }
    }
}

fileprivate extension Text {
    func elementModifier(_ element: TrickleElement) -> Text {
        switch element {
            case .text:
                return self
            case .colored(let coloredElement):
                    return self
                    .foregroundColor(Color(trickleColorName: coloredElement.value.color))
            case .backgroundColored:
                return self
            case .url:
                return self
            case .image:
                return self
            case .embed:
                return self
            case .link:
                return self
                    .foregroundColor(.blue)
            case .nestable(let nestableElement):
                switch nestableElement.type {
                    case .bold:
                        return bold()
                    case .italic:
                        return italic()
                    case .underline:
                        return underline()
                    case .lineThrough:
                        return strikethrough()
                    case .inlineCode:
                        return self
                    case .highlight:
                        return self
                    default:
#if DEBUG
                        fatalError("")
#else
                        return self
#endif
                }
                
            case .user:
                return (Text("@") + self)
                    .foregroundColor(.accentColor)
        }
    }
    
    func elementsModifier(_ element: TrickleElement) -> Text {
        if let elements = element.elements, !elements.isEmpty {
            return Array(elements.enumerated()).map { (i, element) in
                Text(element.text)
                    .elementModifier(element)
            }.reduce(Text(""), +)
        } else {
            return Text(element.text)
                .elementModifier(element)
        }
    }
}
