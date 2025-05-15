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
        
        var color: Color {
            switch self {
            case .brand(let brand):
                brand.color
            case .gray(let gray):
                gray.color
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
            case .black: return .brand100
            case .deep: return .brand200
            case .bright: return .brand300
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
    
}
