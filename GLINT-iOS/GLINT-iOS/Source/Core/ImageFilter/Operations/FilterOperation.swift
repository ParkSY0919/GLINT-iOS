//
//  FilterOperation.swift
//  GLINT-iOS
//
//  Created by Claude on 8/16/25.
//

import Foundation

// MARK: - FilterOperation

/// 필터 변경을 나타내는 개별 연산
enum FilterOperation: Codable, Equatable {
    case setValue(type: FilterPropertyType, value: Float, previousValue: Float)
    case adjustValue(type: FilterPropertyType, delta: Float, fromValue: Float)
    case resetToDefault(type: FilterPropertyType, previousValue: Float)
    case resetAll(previousValues: [FilterPropertyType: Float])
    case applyPreset(presetName: String, previousValues: [FilterPropertyType: Float])
    
    /// 연산의 역연산(Undo용) 생성
    var inverse: FilterOperation {
        switch self {
        case .setValue(let type, _, let previousValue):
            return .setValue(type: type, value: previousValue, previousValue: getCurrentValue(for: type))
            
        case .adjustValue(let type, let delta, let fromValue):
            return .adjustValue(type: type, delta: -delta, fromValue: fromValue + delta)
            
        case .resetToDefault(let type, let previousValue):
            return .setValue(type: type, value: previousValue, previousValue: type.defaultValue)
            
        case .resetAll(let previousValues):
            return FilterOperation.applyValues(previousValues)
            
        case .applyPreset(_, let previousValues):
            return FilterOperation.applyValues(previousValues)
        }
    }
    
    /// 다중 값 적용 연산 (내부 사용)
    private static func applyValues(_ values: [FilterPropertyType: Float]) -> FilterOperation {
        // 현재 값들을 이전 값으로 저장
        var currentValues: [FilterPropertyType: Float] = [:]
        for type in FilterPropertyType.allCases {
            currentValues[type] = getCurrentValue(for: type)
        }
        return .resetAll(previousValues: currentValues)
    }
    
    /// 현재 값 조회 (실제 구현 시 EditViewStore에서 주입)
    private func getCurrentValue(for type: FilterPropertyType) -> Float {
        // 이는 실제로는 외부에서 주입받아야 하는 값
        // 여기서는 기본값으로 처리
        return type.defaultValue
    }
    
    /// 현재 값 조회 (정적 메소드)
    private static func getCurrentValue(for type: FilterPropertyType) -> Float {
        return type.defaultValue
    }
}

// MARK: - FilterOperation Extensions

extension FilterOperation {
    
    /// 연산의 영향을 받는 필터 타입들
    var affectedTypes: Set<FilterPropertyType> {
        switch self {
        case .setValue(let type, _, _), .adjustValue(let type, _, _), .resetToDefault(let type, _):
            return [type]
        case .resetAll(_), .applyPreset(_, _):
            return Set(FilterPropertyType.allCases)
        }
    }
    
    /// 연산의 설명 텍스트
    var description: String {
        switch self {
        case .setValue(let type, let value, _):
            return "\(type.displayName) 값을 \(String(format: "%.2f", value))로 설정"
        case .adjustValue(let type, let delta, _):
            let direction = delta > 0 ? "증가" : "감소"
            return "\(type.displayName) 값을 \(String(format: "%.2f", abs(delta))) \(direction)"
        case .resetToDefault(let type, _):
            return "\(type.displayName) 기본값으로 초기화"
        case .resetAll(_):
            return "모든 필터 초기화"
        case .applyPreset(let presetName, _):
            return "\(presetName) 프리셋 적용"
        }
    }
    
    /// 연산의 중요도 (히스토리 압축 시 사용)
    var priority: Int {
        switch self {
        case .setValue, .adjustValue:
            return 1
        case .resetToDefault:
            return 2
        case .applyPreset:
            return 3
        case .resetAll:
            return 4
        }
    }
    
    /// 같은 타입의 연산인지 확인
    func isSameType(as other: FilterOperation) -> Bool {
        switch (self, other) {
        case (.setValue(let type1, _, _), .setValue(let type2, _, _)),
             (.adjustValue(let type1, _, _), .adjustValue(let type2, _, _)),
             (.resetToDefault(let type1, _), .resetToDefault(let type2, _)):
            return type1 == type2
        case (.resetAll(_), .resetAll(_)),
             (.applyPreset(_, _), .applyPreset(_, _)):
            return true
        default:
            return false
        }
    }
}

// MARK: - FilterOperation Utilities

extension FilterOperation {
    
    /// 연산을 상태 딕셔너리에 적용
    static func apply(_ operation: FilterOperation, to state: inout [FilterPropertyType: Float]) {
        switch operation {
        case .setValue(let type, let value, _):
            state[type] = value
            
        case .adjustValue(let type, let delta, _):
            let currentValue = state[type] ?? type.defaultValue
            let newValue = currentValue + delta
            let range = type.range
            state[type] = min(max(newValue, range.lowerBound), range.upperBound)
            
        case .resetToDefault(let type, _):
            state[type] = type.defaultValue
            
        case .resetAll(_):
            for type in FilterPropertyType.allCases {
                state[type] = type.defaultValue
            }
            
        case .applyPreset(_, let previousValues):
            for (type, value) in previousValues {
                state[type] = value
            }
        }
    }
    
    /// 두 파라미터 상태 간의 차이를 연산으로 변환
    static func diff(from oldParameters: [FilterPropertyType: Float], 
                    to newParameters: [FilterPropertyType: Float]) -> [FilterOperation] {
        var operations: [FilterOperation] = []
        
        for type in FilterPropertyType.allCases {
            let oldValue = oldParameters[type] ?? type.defaultValue
            let newValue = newParameters[type] ?? type.defaultValue
            
            if oldValue != newValue {
                operations.append(.setValue(type: type, value: newValue, previousValue: oldValue))
            }
        }
        
        return operations
    }
    
    /// 연산 시퀀스를 최적화 (연속된 같은 타입의 연산들을 병합)
    static func optimize(_ operations: [FilterOperation]) -> [FilterOperation] {
        guard !operations.isEmpty else { return [] }
        
        var optimized: [FilterOperation] = []
        var currentOperation = operations[0]
        
        for i in 1..<operations.count {
            let nextOperation = operations[i]
            
            if let merged = merge(currentOperation, with: nextOperation) {
                currentOperation = merged
            } else {
                optimized.append(currentOperation)
                currentOperation = nextOperation
            }
        }
        
        optimized.append(currentOperation)
        return optimized
    }
    
    /// 두 연산을 병합 가능한지 확인하고 병합
    private static func merge(_ first: FilterOperation, with second: FilterOperation) -> FilterOperation? {
        switch (first, second) {
        case (.setValue(let type1, _, let firstPrev), .setValue(let type2, let finalValue, _)) where type1 == type2:
            // 연속된 setValue는 마지막 값만 유지
            return .setValue(type: type1, value: finalValue, previousValue: firstPrev)
            
        case (.adjustValue(let type1, let delta1, let from1), .adjustValue(let type2, let delta2, _)) where type1 == type2:
            // 연속된 adjustValue는 델타를 합산
            return .adjustValue(type: type1, delta: delta1 + delta2, fromValue: from1)
            
        default:
            return nil
        }
    }
}

// MARK: - OperationSequence

/// 연산들의 시퀀스를 관리하는 구조체
struct OperationSequence: Codable {
    let operations: [FilterOperation]
    let timestamp: TimeInterval
    let description: String
    
    init(operations: [FilterOperation], description: String = "Filter Operations") {
        self.operations = FilterOperation.optimize(operations)
        self.timestamp = Date().timeIntervalSince1970
        self.description = description
    }
    
    /// 역연산 시퀀스 생성
    var inverse: OperationSequence {
        let inverseOps = operations.reversed().map { $0.inverse }
        return OperationSequence(operations: inverseOps, description: "Undo: \(description)")
    }
    
    /// 영향받는 필터 타입들
    var affectedTypes: Set<FilterPropertyType> {
        return Set(operations.flatMap { $0.affectedTypes })
    }
    
    /// 메모리 사용량 추정 (바이트)
    var estimatedMemoryUsage: Int {
        // FilterOperation당 대략 64바이트 + 기본 구조체 오버헤드
        return operations.count * 64 + 32
    }
}
