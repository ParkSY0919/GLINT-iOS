//
//  BlurFilter.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import CoreImage
import CoreImage.CIFilterBuiltins

struct BlurFilter: ImageFilter {
    let defaultValue: Float = 0.0
    let range: ClosedRange<Float> = 0.0...100.0
    
    func apply(to image: CIImage, value: Float) -> CIImage? {
        guard value > 0 else { return image }
        let filter = CIFilter.gaussianBlur()
        filter.inputImage = image
        filter.radius = value
        return filter.outputImage
    }
} 