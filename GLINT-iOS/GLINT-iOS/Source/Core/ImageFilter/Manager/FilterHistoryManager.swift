//
//  FilterHistoryManager.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import Foundation

// MARK: - FilterHistoryState

/// 필터 상태의 완전한 스냅샷
struct FilterHistoryState {
    let parameters: [FilterPropertyType: Float]
    let timestamp: TimeInterval
    let description: String
    
    init(from editState: PhotoEditState, description: String = "Filter Change") {
        var params: [FilterPropertyType: Float] = [:]
        for (type, parameter) in editState.parameters {
            params[type] = parameter.currentValue
        }
        self.parameters = params
        self.timestamp = Date().timeIntervalSince1970
        self.description = description
    }
    
    init(from parameters: [FilterPropertyType: Float], description: String = "Filter Change") {
        self.parameters = parameters
        self.timestamp = Date().timeIntervalSince1970
        self.description = description
    }
    
    /// FilterParameters로 변환
    func toFilterParameters() -> FilterParameters {
        var filterParams = FilterParameters()
        for (type, value) in parameters {
            switch type {
            case .brightness: filterParams.brightness = value
            case .exposure: filterParams.exposure = value
            case .contrast: filterParams.contrast = value
            case .saturation: filterParams.saturation = value
            case .sharpness: filterParams.sharpness = value
            case .blur: filterParams.blur = value
            case .vignette: filterParams.vignette = value
            case .noiseReduction: filterParams.noiseReduction = value
            case .highlights: filterParams.highlights = value
            case .shadows: filterParams.shadows = value
            case .temperature: filterParams.temperature = value
            case .blackPoint: filterParams.blackPoint = value
            }
        }
        return filterParams
    }
}

// MARK: - FilterHistoryManager

/// 진정한 스택 기반 히스토리 관리자
class FilterHistoryManager {
    
    // MARK: - Properties
    
    private var history: [FilterHistoryState] = []
    private var currentIndex: Int = -1
    
    private let maxHistoryCount: Int
    
    // MARK: - Performance Metrics
    
    private var totalUndoOperations: Int = 0
    private var totalRedoOperations: Int = 0
    private var totalUndoTime: TimeInterval = 0
    private var totalRedoTime: TimeInterval = 0
    
    // MARK: - Initialization
    
    init(maxHistoryCount: Int = 50) {
        self.maxHistoryCount = maxHistoryCount
        
        // 초기 상태 저장 (기본값들)
        let defaultState = createDefaultState()
        saveState(defaultState)
        
        print("📚 FilterHistoryManager 초기화 - 최대 히스토리: \(maxHistoryCount)개")
    }
    
    // MARK: - Core History Management (Stack-based)
    
    /// 새로운 상태를 히스토리 스택에 저장 (LIFO 기반)
    func saveState(_ state: FilterHistoryState) {
        // 현재 인덱스 이후의 모든 상태 제거 (새 작업 시 redo 히스토리 제거)
        if currentIndex < history.count - 1 {
            history.removeSubrange((currentIndex + 1)...)
        }
        
        // 새 상태 추가
        history.append(state)
        currentIndex += 1
        
        // 히스토리 크기 제한
        trimHistoryIfNeeded()
        
        print("💾 상태 저장 - \(state.description) (히스토리: \(history.count)개, 인덱스: \(currentIndex))")
    }
    
    /// Undo 수행 (LIFO - 최근 작업부터 되돌림)
    func undo() -> FilterHistoryState? {
        guard canUndo else {
            print("⚠️ Undo 불가 - 히스토리 없음")
            return nil
        }
        
        let startTime = Date().timeIntervalSince1970
        
        currentIndex -= 1
        let state = history[currentIndex]
        
        // 성능 메트릭 업데이트
        totalUndoOperations += 1
        let operationTime = Date().timeIntervalSince1970 - startTime
        totalUndoTime += operationTime
        
        print("↩️ Undo 수행 - \(state.description) (시간: \(String(format: "%.6f", operationTime))초)")
        return state
    }
    
    /// Redo 수행 (FIFO - 되돌린 작업을 순서대로 다시 실행)
    func redo() -> FilterHistoryState? {
        guard canRedo else {
            print("⚠️ Redo 불가 - 다음 히스토리 없음")
            return nil
        }
        
        let startTime = Date().timeIntervalSince1970
        
        currentIndex += 1
        let state = history[currentIndex]
        
        // 성능 메트릭 업데이트
        totalRedoOperations += 1
        let operationTime = Date().timeIntervalSince1970 - startTime
        totalRedoTime += operationTime
        
        print("↪️ Redo 수행 - \(state.description) (시간: \(String(format: "%.6f", operationTime))초)")
        return state
    }
    
    // MARK: - State Queries
    
    /// Undo 가능 여부
    var canUndo: Bool {
        return currentIndex > 0
    }
    
    /// Redo 가능 여부
    var canRedo: Bool {
        return currentIndex < history.count - 1
    }
    
    /// 현재 상태 반환
    var currentState: FilterHistoryState? {
        guard currentIndex >= 0 && currentIndex < history.count else { return nil }
        return history[currentIndex]
    }
    
    /// 히스토리 개수
    var historyCount: Int {
        return history.count
    }
    
    /// 현재 인덱스
    var currentHistoryIndex: Int {
        return currentIndex
    }
    
    // MARK: - Private Methods
    
    private func trimHistoryIfNeeded() {
        guard history.count > maxHistoryCount else { return }
        
        let removeCount = history.count - maxHistoryCount
        history.removeFirst(removeCount)
        currentIndex = max(0, currentIndex - removeCount)
        
        print("🧹 히스토리 정리 - \(removeCount)개 제거 (현재: \(history.count)개)")
    }
    
    private func createDefaultState() -> FilterHistoryState {
        var defaultParams: [FilterPropertyType: Float] = [:]
        for type in FilterPropertyType.allCases {
            defaultParams[type] = type.defaultValue
        }
        return FilterHistoryState(from: defaultParams, description: "초기 상태")
    }
    
    // MARK: - Performance Analytics
    
    struct PerformanceMetrics {
        let totalUndoOperations: Int
        let totalRedoOperations: Int
        let averageUndoTime: TimeInterval
        let averageRedoTime: TimeInterval
        let historyCount: Int
        let memoryUsage: Double // KB
    }
    
    func getPerformanceMetrics() -> PerformanceMetrics {
        let avgUndoTime = totalUndoOperations > 0 ? totalUndoTime / Double(totalUndoOperations) : 0
        let avgRedoTime = totalRedoOperations > 0 ? totalRedoTime / Double(totalRedoOperations) : 0
        let memoryUsage = estimateMemoryUsage()
        
        return PerformanceMetrics(
            totalUndoOperations: totalUndoOperations,
            totalRedoOperations: totalRedoOperations,
            averageUndoTime: avgUndoTime,
            averageRedoTime: avgRedoTime,
            historyCount: history.count,
            memoryUsage: memoryUsage
        )
    }
    
    func estimateMemoryUsage() -> Double {
        // FilterHistoryState당 대략적인 메모리 사용량 계산
        let stateSize = FilterPropertyType.allCases.count * 4 + 16 + 100 // Float * 개수 + timestamp + description
        return Double(history.count * stateSize) / 1024.0 // KB 단위
    }
    
    // MARK: - Debug Methods
    
    func getHistoryDescriptions() -> [String] {
        return history.map { "\($0.description) (\(Date(timeIntervalSince1970: $0.timestamp).formatted()))" }
    }
    
    func printHistoryDebug() {
        print("🔍 FilterHistoryManager 디버그 정보:")
        for (index, state) in history.enumerated() {
            let marker = index == currentIndex ? "👉" : "  "
            print("\(marker) \(index): \(state.description)")
        }
        print("현재 인덱스: \(currentIndex)")
        print("Can Undo: \(canUndo), Can Redo: \(canRedo)")
        
        let metrics = getPerformanceMetrics()
        print("📊 성능 메트릭:")
        print("   • Undo 횟수: \(metrics.totalUndoOperations), 평균 시간: \(String(format: "%.6f", metrics.averageUndoTime))초")
        print("   • Redo 횟수: \(metrics.totalRedoOperations), 평균 시간: \(String(format: "%.6f", metrics.averageRedoTime))초")
        print("   • 메모리 사용량: \(String(format: "%.2f", metrics.memoryUsage)) KB")
    }
    
    // MARK: - Convenience Methods
    
    func reset() {
        history.removeAll()
        currentIndex = -1
        totalUndoOperations = 0
        totalRedoOperations = 0
        totalUndoTime = 0
        totalRedoTime = 0
        
        // 초기 상태 다시 저장
        let defaultState = createDefaultState()
        saveState(defaultState)
        
        print("🔄 히스토리 매니저 리셋")
    }
}