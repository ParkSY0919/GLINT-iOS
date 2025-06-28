//
//  NoiseReductionFilter.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import CoreImage

struct NoiseReductionFilter: ImageFilter {
    let defaultValue: Float = 0.0
    let range: ClosedRange<Float> = 0.0...1.0
    
    func apply(to image: CIImage, value: Float) -> CIImage? {
        guard value > 0, let filter = CIFilter(name: "CINoiseReduction") else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(value * 0.1, forKey: "inputNoiseLevel")
        filter.setValue(0.5, forKey: "inputSharpness")
        return filter.outputImage
    }
} 