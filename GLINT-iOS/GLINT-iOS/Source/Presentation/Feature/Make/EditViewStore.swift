//
//  EditViewStore.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

@Observable
final class EditViewStore {
    struct State {
        var originalImage: UIImage
        var filteredImage: UIImage
        var showingOriginal: Bool = false
        var selectedPropertyType: FilterPropertyType = .brightness
        var editState: PhotoEditState = PhotoEditState()
        var isSliderActive: Bool = false
        
        var currentValue: Float {
            editState.parameters[selectedPropertyType]?.currentValue ?? selectedPropertyType.defaultValue
        }
        
        init(originalImage: UIImage) {
            self.originalImage = originalImage
            self.filteredImage = originalImage
        }
    }
    
    enum Action {
        case propertySelected(FilterPropertyType)
        case valueChanged(Float)
        case valueChangeEnded(Float)
        case toggleImageView
        case undoButtonTapped
        case redoButtonTapped
        case saveButtonTapped
        case backButtonTapped
    }
    
    var state: State
    private let imageFilterManager = ImageFilterManager()
    
    // 성능 최적화를 위한 변수들
    private let previewSize: CGFloat = 256 // 더욱 작은 프리뷰
    private var basePreviewImage: UIImage // 기본 프리뷰 이미지
    private var currentFilteredPreview: UIImage? // 현재 필터 적용된 프리뷰
    private var lastAppliedParameters: FilterParameters? // 마지막 적용된 파라미터들
    
    init(originalImage: UIImage) {
        self.state = State(originalImage: originalImage)
        // 매우 작은 프리뷰 이미지 생성
        self.basePreviewImage = originalImage.resized(to: previewSize) ?? originalImage
        // 초기 필터 적용
        applyAllFiltersToPreview()
    }
    
    func send(_ action: Action) {
        switch action {
        case .propertySelected(let type):
            let previousType = state.selectedPropertyType
            state.selectedPropertyType = type
            
            // 프리셋 변경 시에도 모든 필터가 적용된 상태 유지
            if previousType != type {
                // 현재 모든 필터가 적용된 프리뷰를 유지
                updateDisplayImage()
            }
            
        case .valueChanged(let value):
            // 실시간으로 파라미터 업데이트
            state.editState.parameters[state.selectedPropertyType]?.currentValue = value
            state.isSliderActive = true
            
            // 실시간 반영 (디바운싱 없이)
            applyCurrentValueToPreview(value)
            
        case .valueChangeEnded(let value):
            state.isSliderActive = false
            
            // 드래그 종료 시 모든 필터를 프리뷰에 재적용하고 히스토리 저장
            applyAllFiltersToPreview()
            state.editState.updateParameter(state.selectedPropertyType, value: value)
            
        case .toggleImageView:
            state.showingOriginal.toggle()
            
        case .undoButtonTapped:
            if state.editState.undo() {
                applyAllFiltersToPreview()
            }
            
        case .redoButtonTapped:
            if state.editState.redo() {
                applyAllFiltersToPreview()
            }
            
        case .saveButtonTapped:
            // 최종 저장 시에만 원본 크기로 필터 적용
            applyAllFiltersToOriginal()
            GTLogger.shared.i("Filter applied and saved")
            
        case .backButtonTapped:
            GTLogger.shared.i("Back button tapped")
        }
    }
    
    // 현재 값만 실시간으로 적용 (가장 효율적)
    private func applyCurrentValueToPreview(_ value: Float) {
        guard let baseFilteredPreview = currentFilteredPreview else {
            applyAllFiltersToPreview()
            return
        }
        
        let currentType = state.selectedPropertyType
        
        do {
            // 기존에 필터가 적용된 프리뷰에서 현재 필터만 다시 적용
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
    
    // 모든 필터를 프리뷰에 적용
    private func applyAllFiltersToPreview() {
        let filterParameters = createFilterParameters()
        
        // 이전과 같은 파라미터면 스킵
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
    
    // 원본 이미지에 모든 필터 적용 (최종 저장용)
    private func applyAllFiltersToOriginal() {
        let filterParameters = createFilterParameters()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                let filteredImage = try self.imageFilterManager.applyFilters(
                    to: self.state.originalImage,
                    with: filterParameters
                )
                
                DispatchQueue.main.async {
                    self.state.filteredImage = filteredImage
                }
            } catch {
                DispatchQueue.main.async {
                    self.state.filteredImage = self.state.originalImage
                }
            }
        }
    }
    
    // 화면에 표시할 이미지 업데이트
    private func updateDisplayImage() {
        if let currentPreview = currentFilteredPreview {
            state.filteredImage = currentPreview
        }
    }
    
    // FilterParameters 생성
    private func createFilterParameters() -> FilterParameters {
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
    
    // 파라미터 비교 함수
    private func areParametersEqual(_ params1: FilterParameters, _ params2: FilterParameters) -> Bool {
        return FilterPropertyType.allCases.allSatisfy { type in
            params1[type] == params2[type]
        }
    }
}

// 더 효율적인 이미지 리사이징
extension UIImage {
    func resized(to maxSize: CGFloat) -> UIImage? {
        let ratio = min(maxSize / size.width, maxSize / size.height)
        if ratio >= 1.0 { return self }
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        // 더 효율적인 리사이징
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
} 
