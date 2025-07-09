//
//  ExposureFilter.swift
//  GLINT-iOS
//
//  Created by 박신영
//

import CoreImage
import CoreImage.CIFilterBuiltins

struct ExposureFilter: ImageFilter {
    let defaultValue: Float = 0.0
    let range: ClosedRange<Float> = -10.0...10.0
    
    func apply(to image: CIImage, value: Float) -> CIImage? {
        let filter = CIFilter.exposureAdjust()
        filter.inputImage = image
        filter.ev = value
        return filter.outputImage
    }
} 
