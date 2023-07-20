//
//  CodeBlockView.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/24.
//

import SwiftUI
import Highlightr
import TrickleCore

public struct CodeBlockView: View {
    var block: TrickleBlock.CodeBlock
    var focused: Binding<Bool>? // equals to editable
    
    @State private var code: AttributedString = .init()
    
    var isFocused: Binding<Bool> {
        Binding {
            focused?.wrappedValue ?? false
        } set: { val in
            if let focused = focused {
                focused.wrappedValue = val
            }
        }

    }
    
    public var body: some View {
        HStack {
            Text(code)
                .onAppear {
                    guard let highlightr = Highlightr() else { return }
                    highlightr.setTheme(to: "paraiso-dark")
                    let code = block.elements.first?.text ?? ""
                    // You can omit the second parameter to use automatic language detection.
                    let highlightedCode = highlightr.highlight(code, as: block.userDefinedValue.language == "plain" ? nil : block.userDefinedValue.language)
                    self.code = AttributedString(highlightedCode ?? .init())
                }
            
            Spacer(minLength: 0)
        }
        .padding(8)
        .background(
            Color(red: 42/255.0, green: 42/255.0, blue: 53/255.0), in: RoundedRectangle(cornerRadius: 6)
        )
    }
}


#if DEBUG
struct CodeBlockView_Previews: PreviewProvider {
    static var previews: some View {
        CodeBlockView(
            block: .init(
                elements: .text("class HelloWorld:\n  def __init__(self):\n    pass\n  def sayHello(self):\n    print(\"Hello, world!\")\nhello = HelloWorld()\nhello.sayHello()"),
                userDefinedValue: TrickleBlock.CodeBlockValue(language: "python")
            )
            )
        .previewLayout(.fixed(width: 500, height: 400))
    }
}
#endif
