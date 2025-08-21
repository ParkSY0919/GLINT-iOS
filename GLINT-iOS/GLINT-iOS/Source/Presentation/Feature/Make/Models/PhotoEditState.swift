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

/// 순수한 필터 상태 관리 (히스토리 관리 제외)
struct PhotoEditState {
    var parameters: [FilterPropertyType: PhotoEditParameter] = [:]
    
    init() {
        for type in FilterPropertyType.allCases {
            parameters[type] = PhotoEditParameter(type: type)
        }
    }
    
    // MARK: - Parameter Management
    
    /// 파라미터 값 즉시 업데이트 (히스토리 관리는 외부에서)
    mutating func updateParameter(_ type: FilterPropertyType, value: Float) {
        parameters[type]?.currentValue = value
    }
    
    /// 특정 파라미터 값 반환
    func getValue(for type: FilterPropertyType) -> Float {
        return parameters[type]?.currentValue ?? type.defaultValue
    }
    
    /// 전체 상태를 다른 상태로 복원
    mutating func restore(from state: FilterHistoryState) {
        for (type, value) in state.parameters {
            parameters[type]?.currentValue = value
        }
    }
    
    /// 현재 상태를 히스토리 상태로 변환
    func toHistoryState(description: String = "Parameter Change") -> FilterHistoryState {
        return FilterHistoryState(from: self, description: description)
    }
    
    /// 기본값으로 리셋
    mutating func resetToDefaults() {
        for type in FilterPropertyType.allCases {
            parameters[type]?.currentValue = type.defaultValue
        }
    }
    
    /// 현재 상태가 기본값과 다른지 확인
    func hasChangesFromDefault() -> Bool {
        return FilterPropertyType.allCases.contains { type in
            let currentValue = parameters[type]?.currentValue ?? type.defaultValue
            return currentValue != type.defaultValue
        }
    }
    
    /// 변경된 파라미터 목록 반환
    func getChangedParameters() -> [FilterPropertyType: Float] {
        var changedParams: [FilterPropertyType: Float] = [:]
        for type in FilterPropertyType.allCases {
            let currentValue = parameters[type]?.currentValue ?? type.defaultValue
            if currentValue != type.defaultValue {
                changedParams[type] = currentValue
            }
        }
        return changedParams
    }
}

