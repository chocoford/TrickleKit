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
                        self.init(hexString: "#DA5959")
                    case .green:
                        self.init(hexString: "#3AAD64")
                    case .yellow:
                        self.init(hexString: "#E2BE2D")
                    case .blue:
                        self.init(hexString: "#70A7EA")
                    case .orange:
                        self.init(hexString: "#E2BE2D")
                    case .pink:
                        self.init(hexString: "#D75D99")
                    case .purple:
                        self.init(hexString: "#A769E3")
                    case .gray:
                        self.init(hexString: "#FFFFFF17")
                }
                
            @unknown default:
                fatalError()
        }
    }
    
    public init (trickleColorName name: String, scheme: ColorScheme = .light) {
        self = Color(FieldOptions.FieldOptionInfo.FieldOptionColor.init(rawValue: name) ?? .gray, scheme: scheme)
    }
}
