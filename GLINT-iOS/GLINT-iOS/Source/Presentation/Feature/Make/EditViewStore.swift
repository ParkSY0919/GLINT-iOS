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
    private var valueChangeTimer: Timer?
    private var filterApplyTimer: Timer?
    private let imageFilterManager = ImageFilterManager()
    
    init(originalImage: UIImage) {
        self.state = State(originalImage: originalImage)
    }
    
    func send(_ action: Action) {
        switch action {
        case .propertySelected(let type):
            state.selectedPropertyType = type
            
        case .valueChanged(let value):
            state.editState.parameters[state.selectedPropertyType]?.currentValue = value
            state.isSliderActive = true
            
            // 필터 적용을 디바운싱 (0.1초 지연)
            filterApplyTimer?.invalidate()
            filterApplyTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                Task { @MainActor in
                    self.applyFiltersWithImageFilterManager()
                }
            }
            
        case .valueChangeEnded(let value):
            state.isSliderActive = false
            // 즉시 필터 적용
            applyFiltersWithImageFilterManager()
            
            // 1초 후 히스토리에 저장
            valueChangeTimer?.invalidate()
            valueChangeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                self.state.editState.updateParameter(self.state.selectedPropertyType, value: value)
            }
            
        case .toggleImageView:
            state.showingOriginal.toggle()
            
        case .undoButtonTapped:
            if state.editState.undo() {
                applyFiltersWithImageFilterManager()
            }
            
        case .redoButtonTapped:
            if state.editState.redo() {
                applyFiltersWithImageFilterManager()
            }
            
        case .saveButtonTapped:
            GTLogger.shared.i("Filter applied and saved")
            
        case .backButtonTapped:
            GTLogger.shared.i("Back button tapped")
        }
    }
    
    // ImageFilterManager를 사용한 통합 필터 적용
    private func applyFiltersWithImageFilterManager() {
        let filterParameters = state.editState.filterParameters
        
        if let filteredImage = imageFilterManager.applyFilters(to: state.originalImage, with: filterParameters) {
            state.filteredImage = filteredImage
        } else {
            state.filteredImage = state.originalImage
        }
    }
} 
