//
//  FilterPropertyType+UI.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

extension FilterPropertyType {
    var iconName: Image {
        switch self {
        case .brightness: return Image(.brightness)
        case .exposure: return Image(.exposure)
        case .contrast: return Image(.contrast)
        case .saturation: return Image(.saturation)
        case .sharpness: return Image(.sharpness)
        case .blur: return Image(.blur)
        case .vignette: return Image(.vignette)
        case .noiseReduction: return Image(.noise)
        case .highlights: return Image(.highlights)
        case .shadows: return Image(.shadows)
        case .temperature: return Image(.temperature)
        case .blackPoint: return Image(.blackPoint)
        }
    }
}
