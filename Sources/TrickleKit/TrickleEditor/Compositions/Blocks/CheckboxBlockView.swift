//
//  CheckboxBlockView.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/22.
//

import SwiftUI

extension TrickleData.Block {
    public struct CheckboxBlockValue: Codable, Hashable {
        let status: CheckboxStatus
        let operatorID: String?
        
        enum CodingKeys: String, CodingKey {
            case status
            case operatorID = "operatorId"
        }
        
        enum CheckboxStatus: String, Codable {
            case unchecked, indeterminate, checked
        }
    }
}

public struct CheckboxBlockView: View {
    @EnvironmentObject var config: TrickleEditorConfig
    var block: TrickleData.Block
    @Binding var text: AttributedString
    var editable: Bool = true
    
    @Binding var focused: Bool
    var onKeydown: ((KeyboardEvent) -> Void)?
    
    public var body: some View {
        if case .checkbox(let value) = block.userDefinedValue {
            content(value)
        } else {
            Text("CheckboxBlockView - Error")
        }
    }
    
    @ViewBuilder private func content(_ value: TrickleData.Block.CheckboxBlockValue) -> some View {
        HStack(spacing: 0) {
            Toggle("", isOn: .constant(value.status == .checked))
                .fixedSize()
            TrickleEditorBlock(text: $text, font: .systemFont(ofSize: config.baseFontSize), editable: editable, focused: $focused, onKeydown: onKeydown)
        }
    }
}

