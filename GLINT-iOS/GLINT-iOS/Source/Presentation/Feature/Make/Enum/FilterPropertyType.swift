//
//  FilterPropertyType.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

enum FilterPropertyType: String, CaseIterable {
    case brightness = "brightness"
    case exposure = "exposure"
    case contrast = "contrast"
    case saturation = "saturation"
    case sharpness = "sharpness"
    case blur = "blur"
    case vignette = "vignette"
    case noiseReduction = "noiseReduction"
    case highlights = "highlights"
    case shadows = "shadows"
    case temperature = "temperature"
    case blackPoint = "blackPoint"
    
    var displayName: String {
        switch self {
        case .brightness: return "BRIGHTNESS"
        case .exposure: return "EXPOSURE"
        case .contrast: return "CONTRAST"
        case .saturation: return "SATURATION"
        case .sharpness: return "SHARPNESS"
        case .blur: return "BLUR"
        case .vignette: return "VIGNETTE"
        case .noiseReduction: return "NOISE REDUCTION"
        case .highlights: return "HIGHLIGHTS"
        case .shadows: return "SHADOWS"
        case .temperature: return "TEMPERATURE"
        case .blackPoint: return "BLACK POINT"
        }
    }
    
    var range: ClosedRange<Float> {
        switch self {
        case .brightness, .highlights, .shadows:
            return -1.0...1.0
        case .exposure:
            return -10.0...10.0
        case .contrast:
            return 0.0...4.0
        case .saturation:
            return 0.0...2.0
        case .sharpness, .noiseReduction, .blackPoint:
            return 0.0...1.0
        case .blur:
            return 0.0...100.0
        case .vignette:
            return 0.0...2.0
        case .temperature:
            return 2000.0...10000.0
        }
    }
    
    var defaultValue: Float {
        switch self {
        case .brightness, .exposure, .highlights, .shadows, .sharpness, .blur, .vignette, .noiseReduction, .blackPoint:
            return 0.0
        case .contrast, .saturation:
            return 1.0
        case .temperature:
            return 6500.0
        }
    }
    
    var step: Float {
        switch self {
        case .temperature:
            return 50.0  // 2000~10000 범위에서 50씩
        case .contrast, .saturation:
            return 0.01  // 0~2 범위에서 0.01씩
        case .exposure:
            return 0.1   // -10~10 범위에서 0.1씩
        case .blur:
            return 1.0   // 0~100 범위에서 1씩
        default:
            return 0.01  // -1~1 범위에서 0.01씩
        }
    }
    
    var iconName: Image {
        switch self {
        case .brightness: return Image(.brightness)
        case .exposure: return Image(.exposure)
        case .contrast: return Image(.contrast)
        case .saturation: return Image(.saturation)
        case .sharpness: return Image(.sharpness)
        case .blur: return Image(.blur)
        case .vignette: return Image(.vignette)
        case .noiseReduction: return Image(.noise)
        case .highlights: return Image(.highlights)
        case .shadows: return Image(.shadows)
        case .temperature: return Image(.temperature)
        case .blackPoint: return Image(.blackPoint)
        }
    }
}

struct PhotoEditParameter {
    var type: FilterPropertyType
    var currentValue: Float
    
    init(type: FilterPropertyType) {
        self.type = type
        self.currentValue = type.defaultValue
    }
}

struct PhotoEditState {
    var parameters: [FilterPropertyType: PhotoEditParameter] = [:]
    var history: [PhotoEditAction] = []
    var historyIndex: Int = -1
    
    init() {
        for type in FilterPropertyType.allCases {
            parameters[type] = PhotoEditParameter(type: type)
        }
    }
    
    mutating func updateParameter(_ type: FilterPropertyType, value: Float) {
        let oldValue = parameters[type]?.currentValue ?? type.defaultValue
        parameters[type]?.currentValue = value
        
        // 값이 변경된 경우에만 히스토리에 추가
        if oldValue != value {
            // 히스토리에 추가 (현재 인덱스 이후 제거)
            if historyIndex < history.count - 1 {
                history.removeSubrange((historyIndex + 1)...)
            }
            
            let action = PhotoEditAction(type: type, oldValue: oldValue, newValue: value)
            history.append(action)
            historyIndex += 1
        }
    }
    
    mutating func undo() -> Bool {
        guard historyIndex >= 0 else { return false }
        
        let action = history[historyIndex]
        parameters[action.type]?.currentValue = action.oldValue
        historyIndex -= 1
        return true
    }
    
    mutating func redo() -> Bool {
        guard historyIndex < history.count - 1 else { return false }
        
        historyIndex += 1
        let action = history[historyIndex]
        parameters[action.type]?.currentValue = action.newValue
        return true
    }
    
    var canUndo: Bool {
        return historyIndex >= 0
    }
    
    var canRedo: Bool {
        return historyIndex < history.count - 1
    }
    
    // FilterParameters로 변환하는 메서드 추가
    var filterParameters: ImageFilterManager.FilterParameters {
        var params = ImageFilterManager.FilterParameters()
        
        params.brightness = parameters[.brightness]?.currentValue ?? 0.0
        params.exposure = parameters[.exposure]?.currentValue ?? 0.0
        params.contrast = parameters[.contrast]?.currentValue ?? 1.0
        params.saturation = parameters[.saturation]?.currentValue ?? 1.0
        params.sharpness = parameters[.sharpness]?.currentValue ?? 0.0
        params.blur = parameters[.blur]?.currentValue ?? 0.0
        params.vignette = parameters[.vignette]?.currentValue ?? 0.0
        params.noiseReduction = parameters[.noiseReduction]?.currentValue ?? 0.0
        params.highlights = parameters[.highlights]?.currentValue ?? 0.0
        params.shadows = parameters[.shadows]?.currentValue ?? 0.0
        params.temperature = parameters[.temperature]?.currentValue ?? 6500.0
        params.blackPoint = parameters[.blackPoint]?.currentValue ?? 0.0
        
        return params
    }
}

struct PhotoEditAction {
    let type: FilterPropertyType
    let oldValue: Float
    let newValue: Float
} 
