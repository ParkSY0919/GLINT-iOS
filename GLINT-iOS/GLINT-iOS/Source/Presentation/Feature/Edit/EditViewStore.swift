//
//  EditViewStore.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

struct EditViewState {
    var originalImage: UIImage?
    var filteredImage: UIImage?
    var showingOriginal: Bool = false
    var selectedPropertyType: FilterPropertyType = .brightness
    var editState: PhotoEditState = PhotoEditState()
    var isSliderActive: Bool = false
    var isInitialized: Bool = false
    
    var currentValue: Float {
        editState.parameters[selectedPropertyType]?.currentValue ?? selectedPropertyType.defaultValue
    }
}

enum EditViewAction {
    case initialize(image: UIImage)
    case propertySelected(FilterPropertyType)
    case valueChanged(Float)
    case valueChangeEnded(Float)
    case toggleImageView
    case undoButtonTapped
    case redoButtonTapped
    case saveButtonTapped
    case backButtonTapped
}

@MainActor
@Observable
final class EditViewStore {
    private(set) var state = EditViewState()
    
    private let router: NavigationRouter<MakeTabRoute>
    private let imageFilterManager = ImageFilterManager()
    
    // 성능 최적화를 위한 변수들
    private let previewSize: CGFloat = 256
    private var basePreviewImage: UIImage?
    private var currentFilteredPreview: UIImage?
    private var lastAppliedParameters: FilterParameters?
    
    // 디바운스 타이머 관련
    private nonisolated(unsafe) var debounceTimer: DispatchSourceTimer?
    private let debounceDelay: TimeInterval = 0.5
    private var pendingHistoryChange: (type: FilterPropertyType, oldValue: Float, newValue: Float)?
    
    init(router: NavigationRouter<MakeTabRoute>) {
        self.router = router
    }
    
    deinit {
        
        // deinit에서는 MainActor 메서드를 호출할 수 없으므로 직접 타이머 정리
        debounceTimer?.cancel()
        debounceTimer = nil
    }
    
    func send(_ action: EditViewAction) {
        switch action {
        case .initialize(let image):
            handleInitialization(with: image)
            
        case .propertySelected(let type):
            handlePropertySelection(type)
            
        case .valueChanged(let value):
            handleValueChange(value)
            
        case .valueChangeEnded(let value):
            handleValueChangeEnded(value)
            
        case .toggleImageView:
            handleImageToggle()
            
        case .undoButtonTapped:
            handleUndo()
            
        case .redoButtonTapped:
            handleRedo()
            
        case .saveButtonTapped:
            handleSave()
            
        case .backButtonTapped:
            handleBack()
        }
    }
}

private extension EditViewStore {
    func handleInitialization(with image: UIImage) {
        state.originalImage = image
        state.filteredImage = image
        state.isInitialized = true
        
        basePreviewImage = image.resized(to: previewSize) ?? image
        applyAllFiltersToPreview()
        
        // 메모리 사용량 분석
        checkImageMemoryUsage()
    }
    
    func handlePropertySelection(_ type: FilterPropertyType) {
        guard state.isInitialized else { return }
        
        let previousType = state.selectedPropertyType
        state.selectedPropertyType = type
        
        if previousType != type {
            // 기존에 대기 중인 히스토리 저장이 있다면 즉시 실행
            if pendingHistoryChange != nil {
                executeHistorySave()
            }
            
            updateDisplayImage()
        }
    }
    
    func handleValueChange(_ value: Float) {
        guard state.isInitialized else { return }
        
        // 즉시 UI 업데이트 (히스토리 저장 안함)
        state.editState.updateParameterImmediately(state.selectedPropertyType, value: value)
        state.isSliderActive = true
        applyCurrentValueToPreview(value)
        
        // 기존 타이머 취소
        cancelDebounceTimer()
        
        print("🔄 슬라이더 조작 중 - \(state.selectedPropertyType.displayName): \(value) (히스토리 저장 안함)")
    }
    
    func handleValueChangeEnded(_ value: Float) {
        guard state.isInitialized else { return }
        
        state.isSliderActive = false
        applyAllFiltersToPreview()
        
        // 디바운스 타이머 시작 (0.5초 후 히스토리 저장)
        scheduleHistorySave(for: state.selectedPropertyType, newValue: value)
        
        print("⏱️ 슬라이더 조작 완료 - \(state.selectedPropertyType.displayName): \(value) (0.5초 후 히스토리 저장)")
    }
    
    func handleImageToggle() {
        guard state.isInitialized else { return }
        state.showingOriginal.toggle()
    }
    
    func handleUndo() {
        guard state.isInitialized else { return }
        
        // 대기 중인 히스토리가 있다면 즉시 저장 후 undo
        if pendingHistoryChange != nil {
            executeHistorySave()
        }
        
        if state.editState.undo() {
            applyAllFiltersToPreview()
        }
    }
    
    func handleRedo() {
        guard state.isInitialized else { return }
        
        // 대기 중인 히스토리가 있다면 즉시 저장 후 redo
        if pendingHistoryChange != nil {
            executeHistorySave()
        }
        
        if state.editState.redo() {
            applyAllFiltersToPreview()
        }
    }
    
    func handleSave() {
        guard state.isInitialized else { return }
        
        applyAllFiltersToOriginal { [weak self] in
            guard let self = self,
                  let filteredImage = self.state.filteredImage else {
                self?.router.pop()
                return
            }
            // 필터된 이미지와 함께 pop
            self.router.pop(withData: filteredImage, addData: state.editState.toFilterPresetsEntity())
            GTLogger.shared.i("Filter applied and saved")
        }
    }
    
    func handleBack() {
        router.pop()
        GTLogger.shared.i("Back button tapped")
    }
    
    // MARK: - Image Processing Methods
    func applyCurrentValueToPreview(_ value: Float) {
        guard let baseFilteredPreview = currentFilteredPreview else {
            applyAllFiltersToPreview()
            return
        }
        
        let currentType = state.selectedPropertyType
        
        do {
            let filteredImage = try imageFilterManager.applyFilters(
                to: baseFilteredPreview,
                filterType: currentType,
                value: value
            )
            state.filteredImage = filteredImage
        } catch {
            state.filteredImage = baseFilteredPreview
        }
    }
    
    func applyAllFiltersToPreview() {
        guard let basePreviewImage = basePreviewImage else { return }
        
        let filterParameters = createFilterParameters()
        
        if let lastParams = lastAppliedParameters, areParametersEqual(filterParameters, lastParams) {
            return
        }
        
        do {
            let filteredPreview = try imageFilterManager.applyFilters(
                to: basePreviewImage,
                with: filterParameters
            )
            currentFilteredPreview = filteredPreview
            state.filteredImage = filteredPreview
            lastAppliedParameters = filterParameters
        } catch {
            currentFilteredPreview = basePreviewImage
            state.filteredImage = basePreviewImage
        }
    }
    
    func applyAllFiltersToOriginal(completion: @escaping () -> Void = {}) {
        guard let originalImage = state.originalImage else {
            completion()
            return
        }
        
        let filterParameters = createFilterParameters()
        
        Task {
            do {
                let filteredImage = try await Task.detached(priority: .userInitiated) {
                    try await self.imageFilterManager.applyFilters(
                        to: originalImage,
                        with: filterParameters
                    )
                }.value
                
                self.state.filteredImage = filteredImage
                completion()
                
            } catch {
                self.state.filteredImage = originalImage
                GTLogger.shared.e("Filter application failed: \(error)")
                completion()
            }
        }
    }
    
    func updateDisplayImage() {
        if let currentPreview = currentFilteredPreview {
            state.filteredImage = currentPreview
        }
    }
    
    func createFilterParameters() -> FilterParameters {
        var filterParameters = FilterParameters()
        
        for (filterType, parameter) in state.editState.parameters {
            let value = parameter.currentValue
            
            if value != filterType.defaultValue {
                switch filterType {
                case .brightness: filterParameters.brightness = value
                case .exposure: filterParameters.exposure = value
                case .contrast: filterParameters.contrast = value
                case .saturation: filterParameters.saturation = value
                case .sharpness: filterParameters.sharpness = value
                case .blur: filterParameters.blur = value
                case .vignette: filterParameters.vignette = value
                case .noiseReduction: filterParameters.noiseReduction = value
                case .highlights: filterParameters.highlights = value
                case .shadows: filterParameters.shadows = value
                case .temperature: filterParameters.temperature = value
                case .blackPoint: filterParameters.blackPoint = value
                }
            }
        }
        
        return filterParameters
    }
    
    func areParametersEqual(_ params1: FilterParameters, _ params2: FilterParameters) -> Bool {
        return FilterPropertyType.allCases.allSatisfy { type in
            params1[type] == params2[type]
        }
    }
    
    // MARK: - Memory Analysis Methods
    private func checkImageMemoryUsage() {
        print("=== 이미지 메모리 사용량 분석 ===")
        
        // 원본 이미지 메모리 사용량
        if let originalImage = state.originalImage {
            let originalMemory = calculateImageMemory(originalImage)
            print("📷 원본 이미지: \(originalImage.size) - \(String(format: "%.2f", originalMemory)) MB")
        }
        
        // 프리뷰 이미지 메모리 사용량
        if let previewImage = basePreviewImage {
            let previewMemory = calculateImageMemory(previewImage)
            print("🔍 프리뷰 이미지: \(previewImage.size) - \(String(format: "%.2f", previewMemory)) MB")
        }
        
        // 메모리 절약 효과 계산
        if let original = state.originalImage, let preview = basePreviewImage {
            let originalMemory = calculateImageMemory(original)
            let previewMemory = calculateImageMemory(preview)
            let savings = ((originalMemory - previewMemory) / originalMemory) * 100
            print("💡 메모리 절약: \(String(format: "%.1f", savings))% (원본 대비)")
            print("📊 메모리 절약량: \(String(format: "%.2f", originalMemory - previewMemory)) MB")
        }
        
        print("================================")
    }
    
    private func calculateImageMemory(_ image: UIImage) -> Double {
        let bytesPerPixel = 4 // RGBA
        let memorySize = image.size.width * image.size.height * CGFloat(bytesPerPixel) * image.scale * image.scale
        return Double(memorySize / 1024 / 1024) // MB 단위
    }
    
    // MARK: - Debounce Timer Management
    
    private func scheduleHistorySave(for type: FilterPropertyType, newValue: Float) {
        // 현재 파라미터에서 이전 값 가져오기 (타이머가 시작되기 전의 값)
        let oldValue = getLastSavedValue(for: type)
        
        // 보류 중인 변경사항 저장
        pendingHistoryChange = (type: type, oldValue: oldValue, newValue: newValue)
        
        // 기존 타이머 취소
        cancelDebounceTimer()
        
        // 새 타이머 생성
        debounceTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        debounceTimer?.schedule(deadline: .now() + debounceDelay)
        debounceTimer?.setEventHandler { [weak self] in
            self?.executeHistorySave()
        }
        debounceTimer?.resume()
    }
    
    private func cancelDebounceTimer() {
        debounceTimer?.cancel()
        debounceTimer = nil
    }
    
    private func executeHistorySave() {
        guard let change = pendingHistoryChange else { return }
        
        // 히스토리에 저장
        state.editState.saveToHistory(
            change.type,
            oldValue: change.oldValue,
            newValue: change.newValue
        )
        
        // 보류 중인 변경사항 초기화
        pendingHistoryChange = nil
        debounceTimer = nil
        
        print("📝 디바운스 완료 - \(change.type.displayName): \(change.oldValue) → \(change.newValue)")
        print("📊 현재 히스토리 개수: \(state.editState.history.count), 인덱스: \(state.editState.historyIndex)")
    }
    
    private func getLastSavedValue(for type: FilterPropertyType) -> Float {
        // 히스토리에서 해당 타입의 마지막 저장 값을 찾기
        // 히스토리가 없거나 해당 타입이 없으면 기본값 반환
        let history = state.editState.history
        let currentIndex = state.editState.historyIndex
        
        // 현재 인덱스에서 역순으로 검색
        for i in stride(from: currentIndex, through: 0, by: -1) {
            let action = history[i]
            if action.type == type {
                return action.newValue
            }
        }
        
        // 히스토리에 없으면 기본값 반환
        return type.defaultValue
    }
}

extension PhotoEditState {
    func toFilterPresetsEntity() -> FilterValuesEntity {
        // 각 값을 개별 변수로 추출
        let brightness = parameters[.brightness]?.currentValue ?? 0
        let exposure = parameters[.exposure]?.currentValue ?? 0
        let contrast = parameters[.contrast]?.currentValue ?? 0
        let saturation = parameters[.saturation]?.currentValue ?? 0
        let sharpness = parameters[.sharpness]?.currentValue ?? 0
        let blur = parameters[.blur]?.currentValue ?? 0
        let vignette = parameters[.vignette]?.currentValue ?? 0
        let noiseReduction = parameters[.noiseReduction]?.currentValue ?? 0
        let highlights = parameters[.highlights]?.currentValue ?? 0
        let shadows = parameters[.shadows]?.currentValue ?? 0
        let temperature = parameters[.temperature]?.currentValue ?? 0
        let blackPoint = parameters[.blackPoint]?.currentValue ?? 0
        
        return FilterValuesEntity(
            brightness: brightness,
            exposure: exposure,
            contrast: contrast,
            saturation: saturation,
            sharpness: sharpness,
            blur: blur,
            vignette: vignette,
            noiseReduction: noiseReduction,
            highlights: highlights,
            shadows: shadows,
            temperature: temperature,
            blackPoint: blackPoint
        )
    }
}
