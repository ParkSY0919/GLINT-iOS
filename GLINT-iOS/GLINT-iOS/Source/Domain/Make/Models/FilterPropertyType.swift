//
//  FilterPropertyType.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import Foundation

enum FilterPropertyType: String, CaseIterable {
    case brightness = "brightness"
    case exposure = "exposure"
    case contrast = "contrast"
    case saturation = "saturation"
    case sharpness = "sharpness"
    case blur = "blur"
    case vignette = "vignette"
    case noiseReduction = "noiseReduction"
    case highlights = "highlights"
    case shadows = "shadows"
    case temperature = "temperature"
    case blackPoint = "blackPoint"
    
    var displayName: String {
        switch self {
        case .brightness: return "BRIGHTNESS"
        case .exposure: return "EXPOSURE"
        case .contrast: return "CONTRAST"
        case .saturation: return "SATURATION"
        case .sharpness: return "SHARPNESS"
        case .blur: return "BLUR"
        case .vignette: return "VIGNETTE"
        case .noiseReduction: return "NOISE REDUCTION"
        case .highlights: return "HIGHLIGHTS"
        case .shadows: return "SHADOWS"
        case .temperature: return "TEMPERATURE"
        case .blackPoint: return "BLACK POINT"
        }
    }
    
    var range: ClosedRange<Float> {
        switch self {
        case .brightness, .highlights, .shadows:
            return -1.0...1.0
        case .exposure:
            return -10.0...10.0
        case .contrast:
            return 0.0...4.0
        case .saturation:
            return 0.0...2.0
        case .sharpness, .noiseReduction, .blackPoint:
            return 0.0...1.0
        case .blur:
            return 0.0...100.0
        case .vignette:
            return 0.0...2.0
        case .temperature:
            return 2000.0...10000.0
        }
    }
    
    var defaultValue: Float {
        switch self {
        case .brightness, .exposure, .highlights, .shadows, .sharpness, .blur, .vignette, .noiseReduction, .blackPoint:
            return 0.0
        case .contrast, .saturation:
            return 1.0
        case .temperature:
            return 6500.0
        }
    }
    
    var step: Float {
        switch self {
        case .temperature:
            return 50.0  // 2000~10000 범위에서 50씩
        case .contrast, .saturation:
            return 0.01  // 0~2 범위에서 0.01씩
        case .exposure:
            return 0.1   // -10~10 범위에서 0.1씩
        case .blur:
            return 1.0   // 0~100 범위에서 1씩
        default:
            return 0.01  // -1~1 범위에서 0.01씩
        }
    }
    
    var category: FilterCategory {
        switch self {
        case .brightness, .exposure, .highlights, .shadows:
            return .exposure
        case .contrast, .saturation, .temperature:
            return .color
        case .sharpness, .blur, .noiseReduction:
            return .detail
        case .vignette, .blackPoint:
            return .effect
        }
    }
}

enum FilterCategory: String, CaseIterable {
    case exposure = "노출"
    case color = "색상"
    case detail = "디테일"
    case effect = "효과"
    
    var displayName: String {
        return self.rawValue
    }
} 
