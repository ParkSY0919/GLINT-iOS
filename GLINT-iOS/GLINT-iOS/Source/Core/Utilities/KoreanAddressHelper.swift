//
//  KoreanAddressHelper.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/23/25.
//

import Foundation
import CoreLocation

struct KoreanAddressHelper {
    static func getKoreanAddress(latitude: Float, longitude: Float) async -> String {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: Double(latitude), longitude: Double(longitude))
        
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
