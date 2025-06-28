//
//  FilterPropertyType+Filter.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import Foundation

// Domain과 Core를 연결하는 확장
extension FilterPropertyType {
    var filter: ImageFilter {
        switch self {
        case .brightness: return BrightnessFilter()
        case .exposure: return ExposureFilter()
        case .contrast: return ContrastFilter()
        case .saturation: return SaturationFilter()
        case .sharpness: return SharpnessFilter()
        case .blur: return BlurFilter()
        case .vignette: return VignetteFilter()
        case .noiseReduction: return NoiseReductionFilter()
        case .highlights: return HighlightsFilter()
        case .shadows: return ShadowsFilter()
        case .temperature: return TemperatureFilter()
        case .blackPoint: return BlackPointFilter()
        }
    }
} 