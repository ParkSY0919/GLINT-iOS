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
    static func formatSmart(_ value: Float) -> String {
        let rounded = (value * 10).rounded() / 10
        if rounded == Float(Int(rounded)) {
            return String(Int(rounded))
        } else {
            return String(format: "%.1f", rounded)
        }
    }
    
    static func photoMetaDataFormat(
        lensInfo: String?,
        focalLength: Float?,
        aperture: Float?,
        iso: Int?
    ) -> String? {
        guard let lensInfo, let focalLength, let aperture, let iso else {
            return nil
        }
        let focalLengthStr =  formatSmart(focalLength)
        let apertureStr = formatSmart(aperture)
        return "\(lensInfo) - \(focalLengthStr)mm 𝒇\(apertureStr) ISO \(iso)"
    }
}
