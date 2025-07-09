//
//  TemperatureFilter.swift
//  GLINT-iOS
//
//  Created by 박신영
//

import CoreImage
import CoreImage.CIFilterBuiltins

struct TemperatureFilter: ImageFilter {
    let defaultValue: Float = 6500.0
    let range: ClosedRange<Float> = 2000.0...10000.0
    
    func apply(to image: CIImage, value: Float) -> CIImage? {
        guard value != 6500 else { return image }
        let filter = CIFilter.temperatureAndTint()
        filter.inputImage = image
        filter.neutral = CIVector(x: CGFloat(value), y: 0)
        filter.targetNeutral = CIVector(x: 6500, y: 0)
        return filter.outputImage
    }
} 
