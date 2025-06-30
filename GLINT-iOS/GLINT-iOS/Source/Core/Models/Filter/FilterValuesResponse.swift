//
//  FilterValuesResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/23/25.
//

import Foundation

struct FilterValuesResponse: ResponseData {
    let brightness: Double?
    let exposure: Double?
    let contrast: Double?
    let saturation: Double?
    let sharpness: Double?
    let blur: Double?
    let vignette: Double?
    let noiseReduction: Double?
    let highlights: Double?
    let shadows: Double?
    let temperature: Int?
    let blackPoint: Double?

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
