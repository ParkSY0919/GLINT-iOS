//
//  SaturationFilter.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import CoreImage
import CoreImage.CIFilterBuiltins

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