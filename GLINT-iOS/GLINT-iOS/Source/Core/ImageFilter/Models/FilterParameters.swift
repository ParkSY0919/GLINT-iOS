//
//  FilterParameters.swift
//  GLINT-iOS
//
//  Created by 박신영
//

import Foundation

struct FilterParameters {
    private var values: [FilterPropertyType: Float] = [:]
    
    init() {
        FilterPropertyType.allCases.forEach { filterType in
            values[filterType] = filterType.defaultValue
        }
    }
    
    subscript(filterType: FilterPropertyType) -> Float {
        get { values[filterType] ?? filterType.defaultValue }
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
