//
//  Int+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import SwiftUI
import MapKit

//TODO: 추후 정리

struct MegapixelCalculator {
    // 문자열로 반환 (MP 단위 포함)
    static func calculateMPString(width: Int, height: Int, fileSize: Int) -> String {
        let mpDouble = Double(width * height) / 1_000_000
        let mp = Int(mpDouble.rounded())
        
        // 파일 크기를 MB로 변환 (바이트를 MB로)
        let fileSizeMB = Double(fileSize) / 1_000_000
        let fileSizeString: String
        
        if fileSizeMB >= 1.0 {
            fileSizeString = String(format: "%.1fMB", fileSizeMB)
        } else {
            // 1MB 미만인 경우 KB로 표시
            let fileSizeKB = Double(fileSize) / 1_000
            fileSizeString = String(format: "%.0fKB", fileSizeKB)
        }
        
        return "\(mp)MP • \(width) × \(height) • \(fileSizeString)"
    }
    
}

// MARK: - 색온도 정규화 유틸리티
struct TemperatureNormalizer {
    
    // MARK: - 상수 정의
    struct Constants {
        static let neutralTemperature: Double = 5500    // 중성 색온도 (0.0 기준점)
        static let minTemperature: Double = 2000        // 최소 색온도 (-1.0)
        static let maxTemperature: Double = 9000        // 최대 색온도 (+1.0)
    }
    
    // MARK: - 1. 기본 선형 변환
    static func normalizeTemperature(_ kelvin: Int) -> Double {
        let kelvin = Double(kelvin)
        let neutral = Constants.neutralTemperature
        let min1 = Constants.minTemperature
        let max1 = Constants.maxTemperature
        
        if kelvin < neutral {
            // 차가운 쪽 (2000K ~ 5500K) → (-1.0 ~ 0.0)
            let ratio = (kelvin - neutral) / (neutral - min1)
            return max(-1.0, ratio)
        } else {
            // 따뜻한 쪽 (5500K ~ 9000K) → (0.0 ~ +1.0)
            let ratio = (kelvin - neutral) / (max1 - neutral)
            return min(1.0, ratio)
        }
    }
    
}

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

struct KoreanAddressHelper {
    
    static func getKoreanAddress(latitude: Double, longitude: Double) async -> String {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            guard let placemark = placemarks.first else {
                return "주소를 찾을 수 없습니다"
            }
            return formatKoreanAddress(from: placemark)
        } catch {
            return "주소 검색 실패: \(error.localizedDescription)"
        }
    }
    
    private static func formatKoreanAddress(from placemark: CLPlacemark) -> String {
        var components: [String] = []
        
        // 시/도
        if let administrativeArea = placemark.administrativeArea {
            let area = administrativeArea
                .replacingOccurrences(of: "특별시", with: "")
                .replacingOccurrences(of: "광역시", with: "")
                .replacingOccurrences(of: "특별자치시", with: "")
                .replacingOccurrences(of: "특별자치도", with: "")
                .replacingOccurrences(of: "도", with: "")
            components.append(area)
        }
        
        // 시/군/구
        if let locality = placemark.locality {
            components.append(locality)
        }
        
        // 도로명 + 건물번호
        if let thoroughfare = placemark.thoroughfare {
            if let subThoroughfare = placemark.subThoroughfare {
                components.append("\(thoroughfare) \(subThoroughfare)")
            } else {
                components.append(thoroughfare)
            }
        } else if let subLocality = placemark.subLocality {
            // 도로명이 없으면 동/읍/면 사용
            components.append(subLocality)
        }
        
        return components.joined(separator: " ")
    }
}
