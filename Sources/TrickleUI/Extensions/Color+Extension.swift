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
    
    public enum TrickleColor: String {
        case red
        case green
        case yellow
        case blue
        case orange
        case pink
        case purple
        case gray
    }
    
    public init(trickleColor color: TrickleColor, scheme: ColorScheme = .light) {
        switch scheme {
            case .light:
                switch color {
                    case .red:
                        self.init(hexString: "#EF4444")
                    case .green:
                        self.init(hexString: "#22C55E")
                    case .yellow:
                        self.init(hexString: "#FACC15")
                    case .blue:
                        self.init(hexString: "#60A5FA")
                    case .orange:
                        self.init(hexString: "#FB923C")
                    case .pink:
                        self.init(hexString: "#EC4899")
                    case .purple:
                        self.init(hexString: "#A855F7")
                    case .gray:
                        self.init(hexString: "#E5E7EB")
                }
                
            case .dark:
                switch color {
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
                
            @unknown default:
                fatalError()
        }
    }
    
    public init(trickleColorName name: String, scheme: ColorScheme = .light) {
        self.init(trickleColor: TrickleColor(rawValue: name) ?? .gray, scheme: scheme)
    }
}
