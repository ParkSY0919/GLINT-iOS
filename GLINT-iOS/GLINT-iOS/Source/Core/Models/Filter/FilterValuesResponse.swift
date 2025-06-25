//
//  FilterValuesResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/23/25.
//

import Foundation
// MARK: - Filter Values
struct FilterValuesResponse: ResponseData {
    let brightness: Double
    let exposure: Double
    let contrast: Double
    let saturation: Double
    let sharpness: Double
    let blur: Double
    let vignette: Double
    let noiseReduction: Double
    let highlights: Double
    let shadows: Double
    let temperature: Int
    let blackPoint: Double

    enum CodingKeys: String, CodingKey {
        case brightness, exposure, contrast, saturation, sharpness, blur, vignette
        case noiseReduction = "noise_reduction"
        case highlights, shadows, temperature
        case blackPoint = "black_point"
    }
    
    func toEntity() -> FilterPresetsEntity {
        return .init(
            brightness: self.brightness,
            exposure: self.exposure,
            contrast: self.contrast,
            saturation: self.saturation,
            sharpness: self.sharpness,
            blur: self.blur,
            vignette: self.vignette,
            noiseReduction: self.noiseReduction,
            highlights: self.highlights,
            shadows: self.shadows,
            temperature: self.temperature,
            blackPoint: self.blackPoint
        )
    }
}
