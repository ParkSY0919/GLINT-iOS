//
//  ImageFilterManager.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import CoreImage
import UIKit
import CoreImage.CIFilterBuiltins
import Metal

// MARK: - Filter Protocol
protocol ImageFilter {
    func apply(to image: CIImage, value: Float) -> CIImage?
    var defaultValue: Float { get }
    var range: ClosedRange<Float> { get }
}

// MARK: - FilterPropertyType Extension for ImageFilter
extension FilterPropertyType {
    var filter: ImageFilter {
        switch self {
        case .brightness: return BrightnessFilter()
        case .exposure: return ExposureFilter()
        case .contrast: return ContrastFilter()
        case .saturation: return SaturationFilter()
        case .sharpness: return SharpnessFilter()
        case .blur: return BlurFilter()
        case .vignette: return VignetteFilter()
        case .noiseReduction: return NoiseReductionFilter()
        case .highlights: return HighlightsFilter()
        case .shadows: return ShadowsFilter()
        case .temperature: return TemperatureFilter()
        case .blackPoint: return BlackPointFilter()
        }
    }
}

// MARK: - Individual Filter Implementations
struct BrightnessFilter: ImageFilter {
    let defaultValue: Float = 0.0
    let range: ClosedRange<Float> = -1.0...1.0
    
    func apply(to image: CIImage, value: Float) -> CIImage? {
        let filter = CIFilter.colorControls()
        filter.inputImage = image
        filter.brightness = value
        return filter.outputImage
    }
}

struct ExposureFilter: ImageFilter {
    let defaultValue: Float = 0.0
    let range: ClosedRange<Float> = -1.0...1.0
    
    func apply(to image: CIImage, value: Float) -> CIImage? {
        let filter = CIFilter.exposureAdjust()
        filter.inputImage = image
        filter.ev = value
        return filter.outputImage
    }
}

struct ContrastFilter: ImageFilter {
    let defaultValue: Float = 1.0
    let range: ClosedRange<Float> = 0.0...2.0
    
    func apply(to image: CIImage, value: Float) -> CIImage? {
        let filter = CIFilter.colorControls()
        filter.inputImage = image
        filter.contrast = value
        return filter.outputImage
    }
}

struct SaturationFilter: ImageFilter {
    let defaultValue: Float = 1.0
    let range: ClosedRange<Float> = 0.0...2.0
    
    func apply(to image: CIImage, value: Float) -> CIImage? {
        let filter = CIFilter.colorControls()
        filter.inputImage = image
        filter.saturation = value
        return filter.outputImage
    }
}

struct SharpnessFilter: ImageFilter {
    let defaultValue: Float = 0.5
    let range: ClosedRange<Float> = -1.0...1.0
    
    func apply(to image: CIImage, value: Float) -> CIImage? {
        guard value > 0 else { return image }
        let filter = CIFilter.sharpenLuminance()
        filter.inputImage = image
        filter.sharpness = value
        return filter.outputImage
    }
}

struct BlurFilter: ImageFilter {
    let defaultValue: Float = 0.0
    let range: ClosedRange<Float> = -1.0...1.0
    
    func apply(to image: CIImage, value: Float) -> CIImage? {
        guard value > 0 else { return image }
        let filter = CIFilter.gaussianBlur()
        filter.inputImage = image
        filter.radius = value
        return filter.outputImage
    }
}

struct VignetteFilter: ImageFilter {
    let defaultValue: Float = 0.0
    let range: ClosedRange<Float> = -1.0...1.0
    
    func apply(to image: CIImage, value: Float) -> CIImage? {
        guard value > 0 else { return image }
        let filter = CIFilter.vignette()
        filter.inputImage = image
        filter.intensity = value
        filter.radius = 2.0
        return filter.outputImage
    }
}

struct NoiseReductionFilter: ImageFilter {
    let defaultValue: Float = 0.0
    let range: ClosedRange<Float> = -1.0...1.0
    
    func apply(to image: CIImage, value: Float) -> CIImage? {
        guard value > 0, let filter = CIFilter(name: "CINoiseReduction") else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(value * 0.1, forKey: "inputNoiseLevel")
        filter.setValue(0.5, forKey: "inputSharpness")
        return filter.outputImage
    }
}

struct HighlightsFilter: ImageFilter {
    let defaultValue: Float = 0.0
    let range: ClosedRange<Float> = -1.0...1.0
    
    func apply(to image: CIImage, value: Float) -> CIImage? {
        let filter = CIFilter.highlightShadowAdjust()
        filter.inputImage = image
        filter.highlightAmount = value
        return filter.outputImage
    }
}

struct ShadowsFilter: ImageFilter {
    let defaultValue: Float = 0.0
    let range: ClosedRange<Float> = -1.0...1.0
    
    func apply(to image: CIImage, value: Float) -> CIImage? {
        let filter = CIFilter.highlightShadowAdjust()
        filter.inputImage = image
        filter.shadowAmount = value
        return filter.outputImage
    }
}

struct TemperatureFilter: ImageFilter {
    let defaultValue: Float = 5800
    let range: ClosedRange<Float> = 2000...10000
    
    func apply(to image: CIImage, value: Float) -> CIImage? {
        guard value != 6500 else { return image }
        let filter = CIFilter.temperatureAndTint()
        filter.inputImage = image
        filter.neutral = CIVector(x: CGFloat(value), y: 0)
        filter.targetNeutral = CIVector(x: 6500, y: 0)
        return filter.outputImage
    }
}

struct BlackPointFilter: ImageFilter {
    let defaultValue: Float = 0.0
    let range: ClosedRange<Float> = -1.0...1.0
    
    func apply(to image: CIImage, value: Float) -> CIImage? {
        guard value > 0, let filter = CIFilter(name: "CIToneCurve") else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: 0, y: CGFloat(value)), forKey: "inputPoint0")
        filter.setValue(CIVector(x: 0.25, y: 0.25), forKey: "inputPoint1")
        filter.setValue(CIVector(x: 0.5, y: 0.5), forKey: "inputPoint2")
        filter.setValue(CIVector(x: 0.75, y: 0.75), forKey: "inputPoint3")
        filter.setValue(CIVector(x: 1, y: 1), forKey: "inputPoint4")
        return filter.outputImage
    }
}

// MARK: - FilterParameters with better structure
struct FilterParameters {
    private var values: [FilterPropertyType: Float] = [:]
    
    init() {
        FilterPropertyType.allCases.forEach { filterType in
            values[filterType] = filterType.filter.defaultValue
        }
    }
    
    subscript(filterType: FilterPropertyType) -> Float {
        get { values[filterType] ?? filterType.filter.defaultValue }
        set { values[filterType] = newValue }
    }
    
    var brightness: Float {
        get { self[.brightness] }
        set { self[.brightness] = newValue }
    }
    
    var exposure: Float {
        get { self[.exposure] }
        set { self[.exposure] = newValue }
    }
    
    var contrast: Float {
        get { self[.contrast] }
        set { self[.contrast] = newValue }
    }
    
    var saturation: Float {
        get { self[.saturation] }
        set { self[.saturation] = newValue }
    }
    
    var sharpness: Float {
        get { self[.sharpness] }
        set { self[.sharpness] = newValue }
    }
    
    var blur: Float {
        get { self[.blur] }
        set { self[.blur] = newValue }
    }
    
    var vignette: Float {
        get { self[.vignette] }
        set { self[.vignette] = newValue }
    }
    
    var noiseReduction: Float {
        get { self[.noiseReduction] }
        set { self[.noiseReduction] = newValue }
    }
    
    var highlights: Float {
        get { self[.highlights] }
        set { self[.highlights] = newValue }
    }
    
    var shadows: Float {
        get { self[.shadows] }
        set { self[.shadows] = newValue }
    }
    
    var temperature: Float {
        get { self[.temperature] }
        set { self[.temperature] = newValue }
    }
    
    var blackPoint: Float {
        get { self[.blackPoint] }
        set { self[.blackPoint] = newValue }
    }
}

// MARK: - Highly Optimized ImageFilterManager
final class ImageFilterManager {
    // Metal GPU 가속을 위한 최적화된 CIContext
    private static let sharedContext: CIContext = {
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            return CIContext(mtlDevice: metalDevice, options: [
                .workingColorSpace: NSNull(),
                .outputColorSpace: NSNull(),
                .cacheIntermediates: false
            ])
        } else {
            return CIContext(options: [
                .workingColorSpace: NSNull(),
                .outputColorSpace: NSNull(),
                .useSoftwareRenderer: false
            ])
        }
    }()
    
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
        let clampedValue = min(max(value, filter.range.lowerBound), filter.range.upperBound)
        
        if clampedValue == filter.defaultValue {
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
            return value != filterType.filter.defaultValue ? (filterType, value) : nil
        }
        
        if activeFilters.isEmpty {
            return image
        }
        
        for (filterType, value) in activeFilters {
            let filter = filterType.filter
            let clampedValue = min(max(value, filter.range.lowerBound), filter.range.upperBound)
            
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
        return filterType.filter.range
    }
    
    func getDefaultValue(for filterType: FilterPropertyType) -> Float {
        return filterType.filter.defaultValue
    }
}

/*
사용법 예시:

// 1. FilterParameters를 사용한 전체 필터 적용
let filterManager = ImageFilterManager()
var parameters = FilterParameters()
parameters.brightness = 0.2
parameters.contrast = 1.1
parameters.saturation = 1.3

do {
    let filteredImage = try filterManager.applyFilters(to: originalImage, with: parameters)
} catch {
    // 에러 처리
}

// 2. 단일 필터 적용
do {
    let filteredImage = try filterManager.applyFilters(to: originalImage, filterType: .brightness, value: 0.5)
} catch {
    // 에러 처리
}

// 3. 여러 필터를 배열로 적용
let filters: [(FilterPropertyType, Float)] = [
    (.brightness, 0.2),
    (.contrast, 1.1),
    (.saturation, 1.3)
]

do {
    let filteredImage = try filterManager.applyFilters(to: originalImage, filters: filters)
} catch {
    // 에러 처리
}
*/
