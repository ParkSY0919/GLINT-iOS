//
//  FilterPresetsEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/23/25.
//

import Foundation

struct FilterPresetsEntity: ResponseData {
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
    var presetValues: [String] {
        return toStringArray()
    }

    enum CodingKeys: String, CodingKey {
        case brightness, exposure, contrast, saturation, sharpness, blur, vignette
        case noiseReduction = "noise_reduction"
        case highlights, shadows, temperature
        case blackPoint = "black_point"
    }

    func toStringArray() -> [String] {
        return [
            String(format: "%.1f", brightness),
            String(format: "%.1f", exposure),
            String(format: "%.1f", contrast),
            String(format: "%.1f", saturation),
            String(format: "%.1f", sharpness),
            String(format: "%.1f", blur),
            String(format: "%.1f", vignette),
            String(format: "%.1f", noiseReduction),
            String(format: "%.1f", highlights),
            String(format: "%.1f", shadows),
            String(format: "%.0f", Double(temperature)),
            String(format: "%.2f", blackPoint)
        ]
    }
}
