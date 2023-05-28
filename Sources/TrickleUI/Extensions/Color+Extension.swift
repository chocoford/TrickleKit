//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/27.
//

import SwiftUI
import TrickleCore
import ChocofordUI

extension Color {
    public init(_ selectOptionColor: FieldOptions.FieldOptionInfo.FieldOptionColor, scheme: ColorScheme = .light) {
        switch scheme {
            case .light:
                switch selectOptionColor {
                    case .red:
                        self.init(hexString: "#FEE2E2")
                    case .green:
                        self.init(hexString: "#DCFCE7")
                    case .yellow:
                        self.init(hexString: "#FEFCE8")
                    case .blue:
                        self.init(hexString: "#DBEAFE")
                    case .orange:
                        self.init(hexString: "#FFEDD5")
                    case .pink:
                        self.init(hexString: "#FCE7F3")
                    case .purple:
                        self.init(hexString: "#F3E8FF")
                    case .gray:
                        self.init(hexString: "#E5E7EB")
                }
                
            case .dark:
                switch selectOptionColor {
                    case .red:
                        self.init(hexString: "#e80707")
                    case .green:
                        self.init(hexString: "#12d956")
                    case .yellow:
                        self.init(hexString: "#e8d40a")
                    case .blue:
                        self.init(hexString: "#0666e6")
                    case .orange:
                        self.init(hexString: "#ea8500")
                    case .pink:
                        self.init(hexString: "#d61a86")
                    case .purple:
                        self.init(hexString: "#7400f3")
                    case .gray:
                        self.init(hexString: "#646e83")
                }
                
            @unknown default:
                fatalError()
        }
    }
}
