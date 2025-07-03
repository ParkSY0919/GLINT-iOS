//
//  FilterValuesResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/23/25.
//

import Foundation

struct FilterValuesResponse: ResponseData, Encodable {
    let brightness: Float?
    let exposure: Float?
    let contrast: Float?
    let saturation: Float?
    let sharpness: Float?
    let blur: Float?
    let vignette: Float?
    let noiseReduction: Float?
    let highlights: Float?
    let shadows: Float?
    let temperature: Float?
    let blackPoint: Float?

    enum CodingKeys: String, CodingKey {
        case brightness, exposure, contrast, saturation, sharpness, blur, vignette
        case noiseReduction = "noise_reduction"
        case highlights, shadows, temperature
        case blackPoint = "black_point"
    }
    
    func toEntity() -> FilterPresetsEntity {
        return .init(
            brightness: self.brightness ?? 0,
            exposure: self.exposure ?? 0,
            contrast: self.contrast ?? 0,
            saturation: self.saturation ?? 0,
            sharpness: self.sharpness ?? 0,
            blur: self.blur ?? 0,
            vignette: self.vignette ?? 0,
            noiseReduction: self.noiseReduction ?? 0,
            highlights: self.highlights ?? 0,
            shadows: self.shadows ?? 0,
            temperature: self.temperature ?? 0,
            blackPoint: self.blackPoint ?? 0
        )
    }
}

extension FilterPresetsEntity {
    func toRequest() -> FilterValuesResponse {
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
