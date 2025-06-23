//
//  FilterValueFormatter.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/23/25.
//

import Foundation

struct FilterValueFormatter {
    // MARK: - 1. 기본 반올림 (소수점 1자리)
    static func format(_ value: Double) -> String {
        return String(format: "%.1f", value)
    }
    
    // MARK: - 2. 조건부 포맷팅 (정수면 .0 제거)
    static func formatSmart(_ value: Double) -> String {
        let rounded = (value * 10).rounded() / 10
        if rounded == Double(Int(rounded)) {
            return String(Int(rounded))
        } else {
            return String(format: "%.1f", rounded)
        }
    }
    
    static func photoMetaDataFormat(
        lensInfo: String,
        focalLength: Double,
        aperture: Double,
        iso: Int
    ) -> String {
        let focalLength =  formatSmart(focalLength)
        let aperture = formatSmart(aperture)
        return "\(lensInfo) - \(focalLength)mm 𝒇\(aperture) ISO \(iso)"
    }
}
