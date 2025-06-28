//
//  PhotoEditState.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import Foundation

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
}

struct PhotoEditAction {
    let type: FilterPropertyType
    let oldValue: Float
    let newValue: Float
} 
