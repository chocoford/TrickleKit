//
//  CheckboxBlockView.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/22.
//

import SwiftUI
import TrickleCore

public struct CheckboxBlockView: View {
    @EnvironmentObject var config: TrickleEditorConfig
    var block: TrickleBlock.ChecklistBlock
    @Binding var text: AttributedString
    var editable: Bool = true
    
    @Binding var focused: Bool
    var onKeydown: ((KeyboardEvent) -> Void)?
    
    public var body: some View {
        content(block.userDefinedValue ?? .unchecked)
    }
    
    @ViewBuilder private func content(_ value: TrickleBlock.CheckboxBlockValue) -> some View {
        HStack(spacing: 0) {
            Toggle("", isOn: .constant(value.status == .checked))
                .fixedSize()
            ElementsRenderer(elements: block.elements)
        }
    }
}

