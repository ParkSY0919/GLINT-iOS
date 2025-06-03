//
//  ImageFilterManager.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

final class ImageFilterManager {
    private let context = CIContext()
    
    struct FilterParameters {
        var brightness: Float = 0.0      // -1 to 1
        var exposure: Float = 0.0        // -10 to 10
        var contrast: Float = 1.0        // 0 to 4
        var saturation: Float = 1.0      // 0 to 2
        var sharpness: Float = 0.0       // 0 to 1
        var blur: Float = 0.0            // 0 to 100
        var vignette: Float = 0.0        // 0 to 2
        var noiseReduction: Float = 0.0  // 0 to 1
        var highlights: Float = 0.0      // -1 to 1
        var shadows: Float = 0.0         // -1 to 1
        var temperature: Float = 6500    // 2000 to 10000
        var blackPoint: Float = 0.0      // 0 to 1
    }
    
    func applyFilters(to image: UIImage, with parameters: FilterParameters) -> UIImage? {
        guard var ciImage = CIImage(image: image) else { return nil }
        
        // 1. Color Controls (brightness, contrast, saturation)
        let colorControlsFilter = CIFilter.colorControls()
        colorControlsFilter.inputImage = ciImage
        colorControlsFilter.brightness = parameters.brightness
        colorControlsFilter.contrast = parameters.contrast
        colorControlsFilter.saturation = parameters.saturation
        if let output = colorControlsFilter.outputImage {
            ciImage = output
        }
        
        // 2. Exposure
        if parameters.exposure != 0 {
            let exposureFilter = CIFilter.exposureAdjust()
            exposureFilter.inputImage = ciImage
            exposureFilter.ev = parameters.exposure
            if let output = exposureFilter.outputImage {
                ciImage = output
            }
        }
        
        // 3. Temperature and Tint
        if parameters.temperature != 6500 {
            let tempFilter = CIFilter.temperatureAndTint()
            tempFilter.inputImage = ciImage
            tempFilter.neutral = CIVector(x: CGFloat(parameters.temperature), y: 0)
            tempFilter.targetNeutral = CIVector(x: 6500, y: 0)
            ciImage = tempFilter.outputImage ?? ciImage
        }
        
        // 4. Highlights and Shadows
        if parameters.highlights != 0 || parameters.shadows != 0 {
            let highlightShadowFilter = CIFilter.highlightShadowAdjust()
            highlightShadowFilter.inputImage = ciImage
            highlightShadowFilter.highlightAmount = parameters.highlights
            highlightShadowFilter.shadowAmount = parameters.shadows
            if let output = highlightShadowFilter.outputImage {
                ciImage = output
            }
        }
        
        // 5. Sharpness
        if parameters.sharpness > 0 {
            let sharpenFilter = CIFilter.sharpenLuminance()
            sharpenFilter.inputImage = ciImage
            sharpenFilter.sharpness = parameters.sharpness
            if let output = sharpenFilter.outputImage {
                ciImage = output
            }
        }
        
        // 6. Gaussian Blur
        if parameters.blur > 0 {
            let blurFilter = CIFilter.gaussianBlur()
            blurFilter.inputImage = ciImage
            blurFilter.radius = parameters.blur
            if let output = blurFilter.outputImage {
                ciImage = output
            }
        }
        
        // 7. Vignette
        if parameters.vignette > 0 {
            let vignetteFilter = CIFilter.vignette()
            vignetteFilter.inputImage = ciImage
            vignetteFilter.intensity = parameters.vignette
            vignetteFilter.radius = 2.0
            if let output = vignetteFilter.outputImage {
                ciImage = output
            }
        }
        
        // 8. Noise Reduction
        if parameters.noiseReduction > 0 {
            guard let noiseFilter = CIFilter(name: "CINoiseReduction") else { return nil }
            noiseFilter.setValue(ciImage, forKey: kCIInputImageKey)
            noiseFilter.setValue(parameters.noiseReduction * 0.1, forKey: "inputNoiseLevel")
            noiseFilter.setValue(0.5, forKey: "inputSharpness")
            if let output = noiseFilter.outputImage {
                ciImage = output
            }
        }
        
        // 9. Black Point adjustment using Tone Curve
        if parameters.blackPoint > 0 {
            guard let toneCurveFilter = CIFilter(name: "CIToneCurve") else { return nil }
            toneCurveFilter.setValue(ciImage, forKey: kCIInputImageKey)
            toneCurveFilter.setValue(CIVector(x: 0, y: CGFloat(parameters.blackPoint)), forKey: "inputPoint0")
            toneCurveFilter.setValue(CIVector(x: 0.25, y: 0.25), forKey: "inputPoint1")
            toneCurveFilter.setValue(CIVector(x: 0.5, y: 0.5), forKey: "inputPoint2")
            toneCurveFilter.setValue(CIVector(x: 0.75, y: 0.75), forKey: "inputPoint3")
            toneCurveFilter.setValue(CIVector(x: 1, y: 1), forKey: "inputPoint4")
            if let output = toneCurveFilter.outputImage {
                ciImage = output
            }
        }
        
        // Convert back to UIImage
        guard let outputCGImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    // Apply single filter for real-time preview
    func applySingleFilter(to image: UIImage, filterType: FilterPropertyType, value: Float) -> UIImage? {
        guard var ciImage = CIImage(image: image) else { return nil }
        
        switch filterType {
        case .brightness:
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.brightness = value
            ciImage = filter.outputImage ?? ciImage
            
        case .exposure:
            let filter = CIFilter.exposureAdjust()
            filter.inputImage = ciImage
            filter.ev = value
            ciImage = filter.outputImage ?? ciImage
            
        case .contrast:
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.contrast = value
            ciImage = filter.outputImage ?? ciImage
            
        case .saturation:
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.saturation = value
            ciImage = filter.outputImage ?? ciImage
            
        case .highlights:
            let filter = CIFilter.highlightShadowAdjust()
            filter.inputImage = ciImage
            filter.highlightAmount = value
            ciImage = filter.outputImage ?? ciImage
            
        case .shadows:
            let filter = CIFilter.highlightShadowAdjust()
            filter.inputImage = ciImage
            filter.shadowAmount = value
            ciImage = filter.outputImage ?? ciImage
            
        case .temperature:
            let filter = CIFilter.temperatureAndTint()
            filter.inputImage = ciImage
            filter.neutral = CIVector(x: CGFloat(value), y: 0)
            filter.targetNeutral = CIVector(x: 6500, y: 0)
            if let output = filter.outputImage {
                ciImage = output
            }
            
        case .sharpness:
            let filter = CIFilter.sharpenLuminance()
            filter.inputImage = ciImage
            filter.sharpness = value
            ciImage = filter.outputImage ?? ciImage
            
        case .blur:
            let filter = CIFilter.gaussianBlur()
            filter.inputImage = ciImage
            filter.radius = value
            ciImage = filter.outputImage ?? ciImage
            
        case .vignette:
            let filter = CIFilter.vignette()
            filter.inputImage = ciImage
            filter.intensity = value
            filter.radius = 2.0
            ciImage = filter.outputImage ?? ciImage
            
        case .noiseReduction:
            if let filter = CIFilter(name: "CINoiseReduction") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(value * 0.1, forKey: "inputNoiseLevel")
                filter.setValue(0.5, forKey: "inputSharpness")
                ciImage = filter.outputImage ?? ciImage
            }
            
        case .blackPoint:
            if let filter = CIFilter(name: "CIToneCurve") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(CIVector(x: 0, y: CGFloat(value)), forKey: "inputPoint0")
                filter.setValue(CIVector(x: 0.25, y: 0.25), forKey: "inputPoint1")
                filter.setValue(CIVector(x: 0.5, y: 0.5), forKey: "inputPoint2")
                filter.setValue(CIVector(x: 0.75, y: 0.75), forKey: "inputPoint3")
                filter.setValue(CIVector(x: 1, y: 1), forKey: "inputPoint4")
                ciImage = filter.outputImage ?? ciImage
            }
        }
        
        guard let outputCGImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
    }
} 
