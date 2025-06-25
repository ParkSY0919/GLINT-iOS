//
//  FilterPreset.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import Foundation

struct FilterPreset {
    let id: String
    let name: String
    let parameters: FilterParameters
    let category: CategoryType
    let thumbnailURL: String?
    let createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        name: String,
        parameters: FilterParameters,
        category: CategoryType,
        thumbnailURL: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.parameters = parameters
        self.category = category
        self.thumbnailURL = thumbnailURL
        self.createdAt = createdAt
    }
}

extension FilterPreset {
    static let vintage = FilterPreset(
        name: "빈티지",
        parameters: {
            var params = FilterParameters()
            params.saturation = 0.7
            params.contrast = 1.2
            params.vignette = 0.3
            return params
        }(),
        category: .푸드
    )
    
    static let bright = FilterPreset(
        name: "밝게",
        parameters: {
            var params = FilterParameters()
            params.brightness = 0.2
            params.exposure = 0.3
            return params
        }(),
        category: .인물
    )
} 