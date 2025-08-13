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
    
    init(router: NavigationRouter<MakeTabRoute>) {
        self.router = router
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
            updateDisplayImage()
        }
    }
    
    func handleValueChange(_ value: Float) {
        guard state.isInitialized else { return }
        
        state.editState.parameters[state.selectedPropertyType]?.currentValue = value
        state.isSliderActive = true
        applyCurrentValueToPreview(value)
    }
    
    func handleValueChangeEnded(_ value: Float) {
        guard state.isInitialized else { return }
        
        state.isSliderActive = false
        applyAllFiltersToPreview()
        state.editState.updateParameter(state.selectedPropertyType, value: value)
    }
    
    func handleImageToggle() {
        guard state.isInitialized else { return }
        state.showingOriginal.toggle()
    }
    
    func handleUndo() {
        guard state.isInitialized else { return }
        
        if state.editState.undo() {
            applyAllFiltersToPreview()
        }
    }
    
    func handleRedo() {
        guard state.isInitialized else { return }
        
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
