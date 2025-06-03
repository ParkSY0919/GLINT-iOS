//
//  FilterPresetsModel.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/2/25.
//

import Foundation

struct FilterPresetsModel: Codable {
    let values: [Double]
    
    func toStringArray() -> [String] {
        return values.map { String(format: "%.1f", $0) }
    }
}
