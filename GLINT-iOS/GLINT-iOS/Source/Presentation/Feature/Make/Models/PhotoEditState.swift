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
    
    // 히스토리 관리 설정
    private let maxHistoryCount = 50
    
    init() {
        for type in FilterPropertyType.allCases {
            parameters[type] = PhotoEditParameter(type: type)
        }
    }
    
    // UI 업데이트용 - 히스토리에 저장하지 않음 (디바운스 대기 중 사용)
    mutating func updateParameterImmediately(_ type: FilterPropertyType, value: Float) {
        parameters[type]?.currentValue = value
    }
    
    // 히스토리 저장용 - 디바운스 후 호출
    mutating func saveToHistory(_ type: FilterPropertyType, oldValue: Float, newValue: Float) {
        // 값이 실제로 변경된 경우에만 히스토리에 추가
        guard oldValue != newValue else { return }
        
        // 히스토리에 추가 (현재 인덱스 이후 제거)
        if historyIndex < history.count - 1 {
            history.removeSubrange((historyIndex + 1)...)
        }
        
        let action = PhotoEditAction(type: type, oldValue: oldValue, newValue: newValue)
        history.append(action)
        historyIndex += 1
        
        // 히스토리 개수 제한
        trimHistoryIfNeeded()
    }
    
    // 기존 메서드 - 기본 동작 유지 (즉시 저장)
    mutating func updateParameter(_ type: FilterPropertyType, value: Float) {
        let oldValue = parameters[type]?.currentValue ?? type.defaultValue
        parameters[type]?.currentValue = value
        saveToHistory(type, oldValue: oldValue, newValue: value)
    }
    
    // 히스토리 개수 제한 및 정리
    private mutating func trimHistoryIfNeeded() {
        guard history.count > maxHistoryCount else { return }
        
        let removeCount = history.count - maxHistoryCount
        history.removeFirst(removeCount)
        historyIndex = max(0, historyIndex - removeCount)
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
