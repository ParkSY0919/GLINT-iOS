//
//  FilterPresetsMapper.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/2/25.
//

import Foundation

struct FilterPresetsMapper {
    static func map(from response: [String: Double]) -> FilterPresetsModel {
        return FilterPresetsModel(values: [
            response["brightness"] ?? 0.0,
            response["exposure"] ?? 0.0,
            response["contrast"] ?? 1.0,
            response["saturation"] ?? 1.0,
            response["sharpness"] ?? 0.0,
            response["blur"] ?? 0.0,
            response["vignette"] ?? 0.0,
            response["noise_reduction"] ?? 0.0,
            response["highlights"] ?? 0.0,
            response["shadows"] ?? 0.0,
            response["temperature"] ?? 0.0,
            response["black_point"] ?? 0.0
        ])
    }
}
