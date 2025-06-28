//
//  TemperatureNormalizer.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/23/25.
//


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