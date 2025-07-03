//
//  FilterValuesEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/23/25.
//

import Foundation

struct FilterValuesEntity: RequestData {
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
    var presetValues: [String] {
        return toStringArray()
    }

    enum CodingKeys: String, CodingKey {
        case brightness, exposure, contrast, saturation, sharpness, blur, vignette
        case noiseReduction = "noise_reduction"
        case highlights, shadows, temperature
        case blackPoint = "black_point"
    }
    
    func setDefaultValues() -> FilterValuesEntity {
        return .init(
            brightness: 0,
            exposure: 0,
            contrast: 0,
            saturation: 0,
            sharpness: 0,
            blur: 0,
            vignette: 0,
            noiseReduction: 0,
            highlights: 0,
            shadows: 0,
            temperature: 6500,
            blackPoint: 0
        )
    }

    func toStringArray() -> [String] {
        return [
            String(format: "%.1f", brightness ?? 0),
            String(format: "%.1f", exposure ?? 0),
            String(format: "%.1f", contrast ?? 1.0),
            String(format: "%.1f", saturation ?? 1.0),
            String(format: "%.1f", sharpness ?? 0),
            String(format: "%.1f", blur ?? 0),
            String(format: "%.1f", vignette ?? 0),
            String(format: "%.1f", noiseReduction ?? 0),
            String(format: "%.1f", highlights ?? 0),
            String(format: "%.1f", shadows ?? 0),
            String(format: "%.0f", temperature ?? 6500),
            String(format: "%.2f", blackPoint ?? 0)
        ]
    }
    
}
