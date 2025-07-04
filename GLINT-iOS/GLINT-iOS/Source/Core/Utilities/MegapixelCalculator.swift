//
//  MegapixelCalculator.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/23/25.
//


struct MegapixelCalculator {
    // 문자열로 반환 (MP 단위 포함)
    static func calculateMPString(width: Int?, height: Int?, fileSize: Int?) -> String? {
        guard let width = width, let height = height, let fileSize = fileSize else {
            return nil
        }
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
