//
//  HighlightsFilter.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import CoreImage
import CoreImage.CIFilterBuiltins

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