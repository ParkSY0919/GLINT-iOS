//
//  DeltaBasedFilterHistoryManager.swift
//  GLINT-iOS
//
//  Created by Claude on 8/16/25.
//

import Foundation

// MARK: - FilterDelta

/// 필터 상태의 변경사항만을 저장하는 델타 구조체
struct FilterDelta: Codable {
    let operationSequence: OperationSequence
    let timestamp: TimeInterval
    let description: String
    
    init(operations: [FilterOperation], description: String = "Filter Change") {
        self.operationSequence = OperationSequence(operations: operations, description: description)
        self.timestamp = Date().timeIntervalSince1970
        self.description = description
    }
    
    init(operationSequence: OperationSequence, description: String = "Filter Change") {
        self.operationSequence = operationSequence
        self.timestamp = Date().timeIntervalSince1970
        self.description = description
    }
    
    /// 역델타 (Undo용)
    var inverse: FilterDelta {
        return FilterDelta(
            operationSequence: operationSequence.inverse,
            description: "Undo: \(description)"
        )
    }
    
    /// 영향받는 필터 타입들
    var affectedTypes: Set<FilterPropertyType> {
        return operationSequence.affectedTypes
    }
    
    /// 메모리 사용량 추정
    var estimatedMemoryUsage: Int {
        return operationSequence.estimatedMemoryUsage + 64 // 기본 구조체 오버헤드
    }
}

// MARK: - DeltaBasedFilterHistoryManager

/// 델타(변경사항) 기반으로 필터 히스토리를 관리하는 매니저
class DeltaBasedFilterHistoryManager {
    
    // MARK: - Properties
    
    private var deltaHistory: [FilterDelta] = []
    private var currentIndex: Int = -1
    private let maxHistoryCount: Int
    
    // 현재 상태 캐싱 (성능 최적화)
    private var cachedCurrentState: [FilterPropertyType: Float]?
    private var lastCacheIndex: Int = -1
    
    // MARK: - Basic Metrics
    
    private var totalUndoOperations: Int = 0
    private var totalRedoOperations: Int = 0
    
    // MARK: - Memory Optimization
    
    private let compressionThreshold: Int = 10 // 10개 이상일 때 압축 고려
    private let maxOperationsPerDelta: Int = 5 // 델타당 최대 연산 수
    
    // MARK: - Initialization
    
    init(maxHistoryCount: Int = 50) {
        self.maxHistoryCount = maxHistoryCount
        
        // 초기 상태는 기본값으로 설정 (델타 없음)
        invalidateCache()
        
        print("📊 DeltaBasedFilterHistoryManager 초기화 - 최대 히스토리: \(maxHistoryCount)개")
    }
    
    // MARK: - Core Delta Management
    
    /// 새로운 델타를 히스토리에 저장
    func saveDelta(_ delta: FilterDelta) {
        // 현재 인덱스 이후의 모든 델타 제거 (새 작업 시 redo 히스토리 제거)
        if currentIndex < deltaHistory.count - 1 {
            deltaHistory.removeSubrange((currentIndex + 1)...)
        }
        
        // 연속된 유사한 연산들을 병합하여 메모리 최적화
        if let optimizedDelta = attemptMergeWithLastDelta(delta) {
            deltaHistory[deltaHistory.count - 1] = optimizedDelta
            print("🔄 델타 병합 - \(optimizedDelta.description)")
        } else {
            // 새 델타 추가
            deltaHistory.append(delta)
            currentIndex += 1
        }
        
        // 히스토리 크기 제한 및 압축
        optimizeHistoryIfNeeded()
        
        // 캐시 무효화
        invalidateCache()
        
        print("💾 델타 저장 - \(delta.description) (히스토리: \(deltaHistory.count)개, 메모리: \(estimateMemoryUsage()) bytes)")
    }
    
    /// 상태 변경을 델타로 변환하여 저장
    func saveStateChanges(from oldState: [FilterPropertyType: Float], 
                         to newState: [FilterPropertyType: Float], 
                         description: String = "Filter Adjustment") {
        let operations = FilterOperation.diff(from: oldState, to: newState)
        
        guard !operations.isEmpty else {
            print("⚠️ 변경사항 없음 - 델타 저장 건너뜀")
            return
        }
        
        let delta = FilterDelta(operations: operations, description: description)
        saveDelta(delta)
    }
    
    /// Undo 수행 (역델타 적용)
    func undo() -> [FilterPropertyType: Float]? {
        guard canUndo else {
            print("⚠️ Undo 불가 - 히스토리 없음")
            return nil
        }
        
        let delta = deltaHistory[currentIndex]
        currentIndex -= 1
        
        // 역델타를 적용하여 상태 복원
        let undoState = reconstructCurrentState()
        
        // 기본 메트릭 업데이트
        totalUndoOperations += 1
        
        print("↩️ Undo 수행 - \(delta.description)")
        return undoState
    }
    
    /// Redo 수행 (델타 재적용)
    func redo() -> [FilterPropertyType: Float]? {
        guard canRedo else {
            print("⚠️ Redo 불가 - 다음 히스토리 없음")
            return nil
        }
        
        currentIndex += 1
        let delta = deltaHistory[currentIndex]
        
        // 델타를 적용하여 상태 복원
        let redoState = reconstructCurrentState()
        
        // 기본 메트릭 업데이트
        totalRedoOperations += 1
        
        print("↪️ Redo 수행 - \(delta.description)")
        return redoState
    }
    
    // MARK: - State Reconstruction
    
    /// 현재 인덱스까지의 모든 델타를 적용하여 현재 상태 복원
    func reconstructCurrentState() -> [FilterPropertyType: Float] {
        // 캐시 확인
        if let cached = cachedCurrentState, lastCacheIndex == currentIndex {
            return cached
        }
        
        // 기본 상태에서 시작
        var state: [FilterPropertyType: Float] = [:]
        for type in FilterPropertyType.allCases {
            state[type] = type.defaultValue
        }
        
        // 현재 인덱스까지의 모든 델타 적용
        if currentIndex >= 0 {
            for i in 0...currentIndex {
                guard i < deltaHistory.count else { break }
                
                let delta = deltaHistory[i]
                applyDelta(delta, to: &state)
            }
        }
        // 캐시 업데이트
        cachedCurrentState = state
        lastCacheIndex = currentIndex
        
        return state
    }
    
    /// 델타를 상태에 적용
    private func applyDelta(_ delta: FilterDelta, to state: inout [FilterPropertyType: Float]) {
        for operation in delta.operationSequence.operations {
            applyOperation(operation, to: &state)
        }
    }
    
    /// 개별 연산을 상태에 적용
    private func applyOperation(_ operation: FilterOperation, to state: inout [FilterPropertyType: Float]) {
        switch operation {
        case .setValue(let type, let value, _):
            state[type] = value
            
        case .adjustValue(let type, let delta, _):
            let currentValue = state[type] ?? type.defaultValue
            let newValue = currentValue + delta
            state[type] = min(max(newValue, type.range.lowerBound), type.range.upperBound)
            
        case .resetToDefault(let type, _):
            state[type] = type.defaultValue
            
        case .resetAll(_):
            for filterType in FilterPropertyType.allCases {
                state[filterType] = filterType.defaultValue
            }
            
        case .applyPreset(_, let values):
            for (type, value) in values {
                state[type] = value
            }
        }
    }
    
    // MARK: - State Queries
    
    /// Undo 가능 여부
    var canUndo: Bool {
        return currentIndex >= 0
    }
    
    /// Redo 가능 여부
    var canRedo: Bool {
        return currentIndex < deltaHistory.count - 1
    }
    
    /// 현재 상태 반환
    var currentState: [FilterPropertyType: Float] {
        return reconstructCurrentState()
    }
    
    /// 히스토리 개수
    var historyCount: Int {
        return deltaHistory.count
    }
    
    /// 현재 인덱스
    var currentHistoryIndex: Int {
        return currentIndex
    }
    
    // MARK: - Memory Optimization
    
    private func optimizeHistoryIfNeeded() {
        // 히스토리 크기 제한
        trimHistoryIfNeeded()
        
        // 압축 가능한 연산들 병합
        if deltaHistory.count > compressionThreshold {
            compressHistory()
        }
    }
    
    private func trimHistoryIfNeeded() {
        guard deltaHistory.count > maxHistoryCount else { return }
        
        let removeCount = deltaHistory.count - maxHistoryCount
        deltaHistory.removeFirst(removeCount)
        currentIndex = max(-1, currentIndex - removeCount)
        
        invalidateCache()
        
        print("🧹 히스토리 정리 - \(removeCount)개 제거 (현재: \(deltaHistory.count)개)")
    }
    
    private func compressHistory() {
        // 연속된 유사한 델타들을 병합
        var compressedHistory: [FilterDelta] = []
        var i = 0
        
        while i < deltaHistory.count {
            var currentDelta = deltaHistory[i]
            var mergeCount = 0
            
            // 연속된 델타들과 병합 시도
            while i + mergeCount + 1 < deltaHistory.count && mergeCount < 3 {
                let nextDelta = deltaHistory[i + mergeCount + 1]
                
                if let merged = attemptMergeDelta(currentDelta, with: nextDelta) {
                    currentDelta = merged
                    mergeCount += 1
                } else {
                    break
                }
            }
            
            compressedHistory.append(currentDelta)
            i += mergeCount + 1
            
            if mergeCount > 0 {
                print("🗜️ 델타 압축 - \(mergeCount + 1)개 병합")
            }
        }
        
        if compressedHistory.count < deltaHistory.count {
            deltaHistory = compressedHistory
            currentIndex = min(currentIndex, deltaHistory.count - 1)
            invalidateCache()
        }
    }
    
    private func attemptMergeWithLastDelta(_ newDelta: FilterDelta) -> FilterDelta? {
        guard let lastDelta = deltaHistory.last else { return nil }
        return attemptMergeDelta(lastDelta, with: newDelta)
    }
    
    private func attemptMergeDelta(_ first: FilterDelta, with second: FilterDelta) -> FilterDelta? {
        // 같은 타입의 필터를 조정하는 연속된 델타들만 병합
        let firstAffected = first.affectedTypes
        let secondAffected = second.affectedTypes
        
        // 교집합이 있고, 둘 다 단일 연산이면 병합 시도
        guard !firstAffected.intersection(secondAffected).isEmpty,
              first.operationSequence.operations.count <= 2,
              second.operationSequence.operations.count <= 2 else {
            return nil
        }
        
        // 연산들을 병합
        let combinedOperations = first.operationSequence.operations + second.operationSequence.operations
        let optimizedOperations = FilterOperation.optimize(combinedOperations)
        
        // 병합된 연산이 더 효율적인 경우에만 병합
        if optimizedOperations.count < combinedOperations.count {
            return FilterDelta(
                operations: optimizedOperations,
                description: "병합: \(first.description) + \(second.description)"
            )
        }
        
        return nil
    }
    
    private func invalidateCache() {
        cachedCurrentState = nil
        lastCacheIndex = -1
    }
    
    private func estimateMemoryUsage() -> Int {
        return deltaHistory.reduce(0) { $0 + $1.estimatedMemoryUsage }
    }
    
    // MARK: - Basic Statistics
    
    func getBasicStats() -> (undoCount: Int, redoCount: Int, historyCount: Int, memoryUsage: Int) {
        return (
            undoCount: totalUndoOperations,
            redoCount: totalRedoOperations,
            historyCount: deltaHistory.count,
            memoryUsage: estimateMemoryUsage()
        )
    }
    
    // MARK: - Debug Methods
    
    func printHistoryDebug() {
        print("🔍 DeltaBasedFilterHistoryManager 디버그 정보:")
        for (index, delta) in deltaHistory.enumerated() {
            let marker = index == currentIndex ? "👉" : "  "
            let operationCount = delta.operationSequence.operations.count
            let memorySize = delta.estimatedMemoryUsage
            print("\(marker) \(index): \(delta.description) (연산 \(operationCount)개, \(memorySize) bytes)")
        }
        print("현재 인덱스: \(currentIndex)")
        print("Can Undo: \(canUndo), Can Redo: \(canRedo)")
        
        let stats = getBasicStats()
        print("📊 기본 통계:")
        print("   • Undo 횟수: \(stats.undoCount)")
        print("   • Redo 횟수: \(stats.redoCount)")
        print("   • 히스토리 개수: \(stats.historyCount)")
        print("   • 메모리 사용량: \(stats.memoryUsage) bytes")
    }
    
    // MARK: - Convenience Methods
    
    func reset() {
        deltaHistory.removeAll()
        currentIndex = -1
        invalidateCache()
        
        // 기본 메트릭 초기화
        totalUndoOperations = 0
        totalRedoOperations = 0
        
        print("🔄 델타 히스토리 매니저 리셋")
    }
}
