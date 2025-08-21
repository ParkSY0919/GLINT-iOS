//
//  FilterChangeTracker.swift
//  GLINT-iOS
//
//  Created by Claude on 8/16/25.
//

import Foundation

// MARK: - FilterChangeTracker

/// 필터 변경사항을 추적하고 델타를 생성하는 트래커
class FilterChangeTracker {
    
    // MARK: - Properties
    
    private var previousState: [FilterPropertyType: Float] = [:]
    private var isTrackingEnabled: Bool = true
    private var changeThreshold: Float = 0.001 // 최소 변경 임계값
    
    // 변경 감지 최적화
    private var lastChangeTime: TimeInterval = 0
    private var debounceInterval: TimeInterval = 0.1 // 100ms 내 변경은 하나로 묶음
    
    // 통계
    private var totalChangesDetected: Int = 0
    private var totalChangesIgnored: Int = 0
    private var totalDeltasGenerated: Int = 0
    
    // MARK: - Initialization
    
    init() {
        // 기본 상태로 초기화
        resetToDefaultState()
        print("📊 FilterChangeTracker 초기화")
    }
    
    // MARK: - State Management
    
    /// 현재 상태를 기준점으로 설정
    func setBaselineState(_ state: [FilterPropertyType: Float]) {
        previousState = state
        print("📍 기준점 설정 - \(state.count)개 필터 값")
    }
    
    /// 기본값으로 초기화
    func resetToDefaultState() {
        previousState = [:]
        for type in FilterPropertyType.allCases {
            previousState[type] = type.defaultValue
        }
        print("🔄 기본 상태로 초기화")
    }
    
    /// 추적 활성화/비활성화
    func setTrackingEnabled(_ enabled: Bool) {
        isTrackingEnabled = enabled
        print("📊 변경 추적 \(enabled ? "활성화" : "비활성화")")
    }
    
    // MARK: - Change Detection
    
    /// 새로운 상태와 이전 상태를 비교하여 변경사항 감지
    func detectChanges(in newState: [FilterPropertyType: Float]) -> FilterDelta? {
        guard isTrackingEnabled else { return nil }
        
        let currentTime = Date().timeIntervalSince1970
        
        // 디바운스 체크
        if currentTime - lastChangeTime < debounceInterval {
            totalChangesIgnored += 1
            return nil
        }
        
        let changes = detectIndividualChanges(from: previousState, to: newState)
        
        guard !changes.isEmpty else {
            totalChangesIgnored += 1
            return nil
        }
        
        // 변경사항을 연산으로 변환
        let operations = changes.map { change in
            FilterOperation.setValue(
                type: change.type,
                value: change.newValue,
                previousValue: change.oldValue
            )
        }
        
        // 델타 생성
        let delta = FilterDelta(
            operations: operations,
            description: generateChangeDescription(changes)
        )
        
        // 상태 업데이트
        previousState = newState
        lastChangeTime = currentTime
        
        // 통계 업데이트
        totalChangesDetected += changes.count
        totalDeltasGenerated += 1
        
        print("🔍 변경 감지 - \(changes.count)개 필터 변경됨")
        
        return delta
    }
    
    /// 특정 필터 타입의 값 변경 추적
    func trackSingleChange(type: FilterPropertyType, newValue: Float) -> FilterDelta? {
        guard isTrackingEnabled else { return nil }
        
        let oldValue = previousState[type] ?? type.defaultValue
        
        // 임계값 체크
        if abs(newValue - oldValue) < changeThreshold {
            totalChangesIgnored += 1
            return nil
        }
        
        let operation = FilterOperation.setValue(
            type: type,
            value: newValue,
            previousValue: oldValue
        )
        
        let delta = FilterDelta(
            operations: [operation],
            description: "\(type.displayName) 조정"
        )
        
        // 상태 업데이트
        previousState[type] = newValue
        lastChangeTime = Date().timeIntervalSince1970
        
        // 통계 업데이트
        totalChangesDetected += 1
        totalDeltasGenerated += 1
        
        return delta
    }
    
    /// 연속된 값 변경을 하나의 델타로 병합
    func trackContinuousChange(type: FilterPropertyType, 
                              startValue: Float, 
                              endValue: Float) -> FilterDelta? {
        guard isTrackingEnabled else { return nil }
        
        // 임계값 체크
        if abs(endValue - startValue) < changeThreshold {
            totalChangesIgnored += 1
            return nil
        }
        
        let operation = FilterOperation.setValue(
            type: type,
            value: endValue,
            previousValue: startValue
        )
        
        let delta = FilterDelta(
            operations: [operation],
            description: "\(type.displayName) 연속 조정"
        )
        
        // 상태 업데이트
        previousState[type] = endValue
        
        // 통계 업데이트
        totalChangesDetected += 1
        totalDeltasGenerated += 1
        
        return delta
    }
    
    // MARK: - Advanced Change Detection
    
    /// 여러 타입의 필터를 동시에 변경하는 경우 (프리셋 적용 등)
    func trackBatchChanges(_ changes: [FilterPropertyType: Float], 
                          description: String = "일괄 변경") -> FilterDelta? {
        guard isTrackingEnabled else { return nil }
        
        var operations: [FilterOperation] = []
        
        for (type, newValue) in changes {
            let oldValue = previousState[type] ?? type.defaultValue
            
            if abs(newValue - oldValue) >= changeThreshold {
                operations.append(.setValue(
                    type: type,
                    value: newValue,
                    previousValue: oldValue
                ))
                
                previousState[type] = newValue
            }
        }
        
        guard !operations.isEmpty else {
            totalChangesIgnored += 1
            return nil
        }
        
        let delta = FilterDelta(operations: operations, description: description)
        
        // 통계 업데이트
        totalChangesDetected += operations.count
        totalDeltasGenerated += 1
        
        return delta
    }
    
    /// 상대적 변경 추적 (델타 값으로)
    func trackRelativeChange(type: FilterPropertyType, delta: Float) -> FilterDelta? {
        guard isTrackingEnabled else { return nil }
        
        let currentValue = previousState[type] ?? type.defaultValue
        let newValue = min(max(currentValue + delta, type.range.lowerBound), type.range.upperBound)
        
        // 실제 변경이 없으면 무시
        if abs(newValue - currentValue) < changeThreshold {
            totalChangesIgnored += 1
            return nil
        }
        
        let operation = FilterOperation.adjustValue(
            type: type,
            delta: newValue - currentValue,
            fromValue: currentValue
        )
        
        let filterDelta = FilterDelta(
            operations: [operation],
            description: "\(type.displayName) 상대 조정"
        )
        
        // 상태 업데이트
        previousState[type] = newValue
        
        // 통계 업데이트
        totalChangesDetected += 1
        totalDeltasGenerated += 1
        
        return filterDelta
    }
    
    // MARK: - Helper Methods
    
    private func detectIndividualChanges(from oldState: [FilterPropertyType: Float], 
                                       to newState: [FilterPropertyType: Float]) -> [FilterChange] {
        var changes: [FilterChange] = []
        
        for type in FilterPropertyType.allCases {
            let oldValue = oldState[type] ?? type.defaultValue
            let newValue = newState[type] ?? type.defaultValue
            
            if abs(newValue - oldValue) >= changeThreshold {
                changes.append(FilterChange(
                    type: type,
                    oldValue: oldValue,
                    newValue: newValue
                ))
            }
        }
        
        return changes
    }
    
    private func generateChangeDescription(_ changes: [FilterChange]) -> String {
        if changes.count == 1 {
            let change = changes[0]
            return "\(change.type.displayName) 조정"
        } else if changes.count <= 3 {
            let names = changes.map { $0.type.displayName }
            return "\(names.joined(separator: ", ")) 조정"
        } else {
            return "\(changes.count)개 필터 조정"
        }
    }
    
    // MARK: - State Queries
    
    /// 현재 추적 중인 상태
    var currentTrackedState: [FilterPropertyType: Float] {
        return previousState
    }
    
    /// 특정 타입의 현재 값
    func getCurrentValue(for type: FilterPropertyType) -> Float {
        return previousState[type] ?? type.defaultValue
    }
    
    /// 마지막 변경 시간
    var lastChangeTimestamp: TimeInterval {
        return lastChangeTime
    }
    
    // MARK: - Statistics
    
    struct TrackingStatistics {
        let totalChangesDetected: Int
        let totalChangesIgnored: Int
        let totalDeltasGenerated: Int
        let changeEfficiencyRatio: Double // 실제 델타 생성 비율
        let averageChangesPerDelta: Double
    }
    
    func getStatistics() -> TrackingStatistics {
        let total = totalChangesDetected + totalChangesIgnored
        let efficiencyRatio = total > 0 ? Double(totalChangesDetected) / Double(total) : 1.0
        let avgChangesPerDelta = totalDeltasGenerated > 0 ? 
            Double(totalChangesDetected) / Double(totalDeltasGenerated) : 0.0
        
        return TrackingStatistics(
            totalChangesDetected: totalChangesDetected,
            totalChangesIgnored: totalChangesIgnored,
            totalDeltasGenerated: totalDeltasGenerated,
            changeEfficiencyRatio: efficiencyRatio,
            averageChangesPerDelta: avgChangesPerDelta
        )
    }
    
    // MARK: - Configuration
    
    /// 변경 감지 임계값 설정
    func setChangeThreshold(_ threshold: Float) {
        changeThreshold = threshold
        print("⚙️ 변경 임계값 설정: \(threshold)")
    }
    
    /// 디바운스 간격 설정
    func setDebounceInterval(_ interval: TimeInterval) {
        debounceInterval = interval
        print("⚙️ 디바운스 간격 설정: \(interval)초")
    }
    
    // MARK: - Debug
    
    func printDebugInfo() {
        let stats = getStatistics()
        print("🔍 FilterChangeTracker 디버그 정보:")
        print("   • 감지된 변경: \(stats.totalChangesDetected)")
        print("   • 무시된 변경: \(stats.totalChangesIgnored)")
        print("   • 생성된 델타: \(stats.totalDeltasGenerated)")
        print("   • 효율성: \(String(format: "%.1f", stats.changeEfficiencyRatio * 100))%")
        print("   • 델타당 평균 변경: \(String(format: "%.1f", stats.averageChangesPerDelta))")
        print("   • 변경 임계값: \(changeThreshold)")
        print("   • 디바운스 간격: \(debounceInterval)초")
    }
}

// MARK: - Supporting Types

/// 개별 필터 변경을 나타내는 구조체
private struct FilterChange {
    let type: FilterPropertyType
    let oldValue: Float
    let newValue: Float
    
    var delta: Float {
        return newValue - oldValue
    }
    
    var changePercentage: Float {
        guard oldValue != 0 else { return 0 }
        return abs(delta / oldValue) * 100
    }
}
