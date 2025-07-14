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
}
