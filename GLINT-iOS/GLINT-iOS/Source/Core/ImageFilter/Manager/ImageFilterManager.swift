//
//  ImageFilterManager.swift
//  GLINT-iOS
//
//  Created by 박신영
//

import CoreImage
import UIKit

final class ImageFilterManager {
    private static let sharedContext = CIContext()
    
    private let context = ImageFilterManager.sharedContext
    
    enum FilterError: Error {
        case invalidImage
        case filterApplicationFailed(FilterPropertyType)
        case contextCreationFailed
    }
    
    // 단일 필터 적용 (실시간 프리뷰용)
    func applyFilters(to image: UIImage, filterType: FilterPropertyType, value: Float) throws -> UIImage {
        guard let ciImage = CIImage(image: image) else {
            throw FilterError.invalidImage
        }
        
        let filter = filterType.filter
        let clampedValue = min(max(value, filterType.range.lowerBound), filterType.range.upperBound)
        
        if clampedValue == filterType.defaultValue {
            return image
        }
        
        guard let filteredCIImage = filter.apply(to: ciImage, value: clampedValue) else {
            throw FilterError.filterApplicationFailed(filterType)
        }
        
        return try createUIImage(from: filteredCIImage, originalImage: image)
    }
    
    // 전체 필터 체인 적용 (최종 결과용)
    func applyFilters(to image: UIImage, with parameters: FilterParameters) throws -> UIImage {
        guard var ciImage = CIImage(image: image) else {
            throw FilterError.invalidImage
        }
        
        let activeFilters: [(FilterPropertyType, Float)] = FilterPropertyType.allCases.compactMap { filterType in
            let value = parameters[filterType]
            return value != filterType.defaultValue ? (filterType, value) : nil
        }
        
        if activeFilters.isEmpty {
            return image
        }
        
        for (filterType, value) in activeFilters {
            let filter = filterType.filter
            let clampedValue = min(max(value, filterType.range.lowerBound), filterType.range.upperBound)
            
            if let filteredImage = filter.apply(to: ciImage, value: clampedValue) {
                ciImage = filteredImage
            }
        }
        
        return try createUIImage(from: ciImage, originalImage: image)
    }
    
    private func createUIImage(from ciImage: CIImage, originalImage: UIImage) throws -> UIImage {
        let extent = ciImage.extent.isInfinite ? 
            CGRect(origin: .zero, size: originalImage.size) : 
            ciImage.extent
        
        guard let outputCGImage = context.createCGImage(ciImage, from: extent) else {
            throw FilterError.contextCreationFailed
        }
        
        return UIImage(cgImage: outputCGImage, scale: originalImage.scale, orientation: originalImage.imageOrientation)
    }
}

// MARK: - Usage Examples
extension ImageFilterManager {
    // 편의 메서드들
    func resetParameters() -> FilterParameters {
        return FilterParameters()
    }
    
    func getFilterRange(for filterType: FilterPropertyType) -> ClosedRange<Float> {
        return filterType.range
    }
    
    func getDefaultValue(for filterType: FilterPropertyType) -> Float {
        return filterType.defaultValue
    }
} 
