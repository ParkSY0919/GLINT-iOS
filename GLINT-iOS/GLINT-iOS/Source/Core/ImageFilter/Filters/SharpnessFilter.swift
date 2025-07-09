//
//  SharpnessFilter.swift
//  GLINT-iOS
//
//  Created by 박신영
//

import CoreImage
import CoreImage.CIFilterBuiltins

struct SharpnessFilter: ImageFilter {
    let defaultValue: Float = 0.0
    let range: ClosedRange<Float> = 0.0...1.0
    
    func apply(to image: CIImage, value: Float) -> CIImage? {
        guard value > 0 else { return image }
        let filter = CIFilter.sharpenLuminance()
        filter.inputImage = image
        filter.sharpness = value
        return filter.outputImage
    }
} 
