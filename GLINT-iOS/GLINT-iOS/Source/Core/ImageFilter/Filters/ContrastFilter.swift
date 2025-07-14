//
//  ContrastFilter.swift
//  GLINT-iOS
//
//  Created by 박신영
//

import CoreImage
import CoreImage.CIFilterBuiltins

struct ContrastFilter: ImageFilter {
    let defaultValue: Float = 1.0
    let range: ClosedRange<Float> = 0.0...4.0
    
    func apply(to image: CIImage, value: Float) -> CIImage? {
        let filter = CIFilter.colorControls()
        filter.inputImage = image
        filter.contrast = value
        return filter.outputImage
    }
} 
