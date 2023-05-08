//
//  View+Extension.swift
//  
//
//  Created by Chocoford on 2023/4/4.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    public func trickleChipDecorator(_ option: FieldOptions.FieldOptionInfo, colorScheme: ColorScheme) -> some View {
        self
            .padding(.horizontal, 6)
            .background(
                Color(option.color, scheme: colorScheme), in: RoundedRectangle(cornerRadius: 4)
            )
    }
}
