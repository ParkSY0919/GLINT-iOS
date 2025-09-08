//
//  GLINTColor.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

enum GLINTColor {
    case palette(Palette)
    
    var color: Color {
        switch self {
        case .palette(let palette): return palette.color
        }
    }
}
    
extension GLINTColor {
    
    enum Palette {
        case brand(Brand)
        case gray(Gray)
        case slider(Slider)
        
        var color: Color {
            switch self {
            case .brand(let brand):
                brand.color
            case .gray(let gray):
                gray.color
            case .slider(let slider):
                slider.color
            }
        }
    }
    
}

extension GLINTColor.Palette {
    
    enum Brand {
        case black
        case deep
        case bright
        
        var color: Color {
            switch self {
            case .black: return .brandBlack
            case .deep: return .brandDeep
            case .bright: return .brandBright
            }
        }
    }
    
    enum Gray {
        case g0
        case g15
        case g30
        case g45
        case g60
        case g75
        case g90
        case g100
        
        var color: Color {
            switch self {
            case .g0: return .gray0
            case .g15: return .gray15
            case .g30: return .gray30
            case .g45: return .gray45
            case .g60: return .gray60
            case .g75: return .gray75
            case .g90: return .gray90
            case .g100: return .gray100
            }
        }
    }
    
    enum Slider {
        case left
        case right
        
        var color: Color {
            switch self {
            case .left: .sliderLeft
            case .right: .sliderRight
            }
        }
    }
    
}

extension Color {
    static let glintPrimary = Color(red: 0.2, green: 0.6, blue: 1.0)
    static let glintSecondary = Color(red: 0.85, green: 0.95, blue: 1.0)
    static let glintAccent = Color(red: 1.0, green: 0.4, blue: 0.6)
    static let glintBackground = Color(red: 0.97, green: 0.98, blue: 1.0)
    static let glintCardBackground = Color.white
    static let glintTextPrimary = Color(red: 0.1, green: 0.1, blue: 0.2)
    static let glintTextSecondary = Color(red: 0.4, green: 0.4, blue: 0.5)
    static let glintSuccess = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let glintWarning = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let glintError = Color(red: 1.0, green: 0.3, blue: 0.3)
    
    // MARK: - Pinterest-Inspired Dark Theme Colors
    
    // Primary dark theme background
    static let pinterestDarkBg = Color(red: 0.067, green: 0.067, blue: 0.067) // #111111
    static let pinterestDarkSurface = Color(red: 0.118, green: 0.118, blue: 0.118) // #1E1E1E
    static let pinterestDarkCard = Color(red: 0.157, green: 0.157, blue: 0.157) // #282828
    
    // Teal-inspired accent colors (#3B5B69 계열)
    static let pinterestRed = Color(red: 0.231, green: 0.357, blue: 0.412) // #3B5B69
    static let pinterestRedSoft = Color(red: 0.231, green: 0.357, blue: 0.412, opacity: 0.1)
    static let pinterestGold = Color(red: 0.427, green: 0.635, blue: 0.710) // #6DA2B5 (lighter teal)
    static let pinterestBlue = Color(red: 0.188, green: 0.298, blue: 0.357) // #304C5B (darker teal)
    
    // Text colors for dark theme
    static let pinterestTextPrimary = Color(red: 0.95, green: 0.95, blue: 0.95) // #F2F2F2
    static let pinterestTextSecondary = Color(red: 0.7, green: 0.7, blue: 0.7) // #B3B3B3
    static let pinterestTextTertiary = Color(red: 0.5, green: 0.5, blue: 0.5) // #808080
    
    // Glassmorphism colors
    static let glassLight = Color.white.opacity(0.1)
    static let glassDark = Color.black.opacity(0.2)
    static let glassStroke = Color.white.opacity(0.2)
    
    // Gradient colors (Teal theme)
    static let gradientStart = Color(red: 0.231, green: 0.357, blue: 0.412) // #3B5B69
    static let gradientMid = Color(red: 0.427, green: 0.635, blue: 0.710) // #6DA2B5
    static let gradientEnd = Color(red: 0.325, green: 0.502, blue: 0.573) // #536B92 (blue-teal)
    
    // Interactive states
    static let pinterestHover = Color.white.opacity(0.05)
    static let pinterestPressed = Color.white.opacity(0.1)
    static let pinterestFocused = pinterestRed.opacity(0.3)
    
    // Status colors for dark theme
    static let pinterestSuccess = Color(red: 0.0, green: 0.8, blue: 0.4) // #00CC66
    static let pinterestWarning = Color(red: 1.0, green: 0.6, blue: 0.0) // #FF9900
    static let pinterestError = Color(red: 1.0, green: 0.2, blue: 0.2) // #FF3333
}
