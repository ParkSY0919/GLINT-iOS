//
//  ImageConverter.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/25/25.
//

import SwiftUI

struct ImageConverter {
    enum ImageConversionError: Error {
        case originalImageConversionFailed
        case filteredImageConversionFailed
        
        var errorDescription: String? {
            switch self {
            case .originalImageConversionFailed:
                return "원본 이미지 데이터 변환 실패"
            case .filteredImageConversionFailed:
                return "필터 이미지 데이터 변환 실패"
            }
        }
    }
    
    static func convertToData(
        originalImage: UIImage?,
        filteredImage: UIImage?,
        compressionQuality: Double = 0.7
    ) throws -> [Data] {
        guard let originalData = originalImage?.jpegData(compressionQuality: compressionQuality) else {
            throw ImageConversionError.originalImageConversionFailed
        }
        
        let filteredData: Data
        if let filteredImage = filteredImage {
            guard let data = filteredImage.jpegData(compressionQuality: compressionQuality) else {
                throw ImageConversionError.filteredImageConversionFailed
            }
            filteredData = data
        } else {
            filteredData = originalData
        }
        
        return [originalData, filteredData]
    }
    
    static func convertToData(
        images: [UIImage?],
        compressionQuality: Double = 0.7
    ) throws -> [Data] {
        var result = [Data]()
        for i in images {
            guard let originalData = i?.jpegData(compressionQuality: compressionQuality) else {
                throw ImageConversionError.originalImageConversionFailed
            }
            result.append(originalData)
        }
        
        return result
    }
}
