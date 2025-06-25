//
//  MakeViewStore.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI
import PhotosUI

struct MakeViewState {
    var filterName: String = ""
    var selectedCategory: CategoryType? = nil
    var selectedImage: UIImage?
    var filteredImage: UIImage?
    var imageMetaData: PhotoMetadata?
    var address: String?
    var introduce: String = ""
    var price: String = ""
    var showingEditView: Bool = false
    
    var isLoading: Bool = false
    var errorMessage: String?
    var saveResult: [String]? = nil
    var showingSaveAlert: Bool = false
}

enum MakeViewAction {
    case filterNameChanged(String)
    case categorySelected(CategoryType)
    case imageSelected(UIImage, PhotoMetadata?)
    case imageChangeRequested
    case editButtonTapped
    case editViewDismissed
    case filteredImageReceived(UIImage)
    case introduceChanged(String)
    case priceChanged(String)
    case saveButtonTapped
    case retryButtonTapped
}

@MainActor
@Observable
final class MakeViewStore {
    private(set) var state = MakeViewState()
    private let useCase: MakeViewUseCase
    
    init(useCase: MakeViewUseCase) {
        self.useCase = useCase
    }
    
    func send(_ action: MakeViewAction) {
        switch action {
        case .filterNameChanged(let name):
            state.filterName = name
            
        case .categorySelected(let category):
            state.selectedCategory = category
            
        case .imageSelected(let image, let metadata):
            state.selectedImage = image
            extractImageMetaData(image: image, meta: metadata)
            
        case .imageChangeRequested:
            // 이미지 변경 요청 처리
            GTLogger.shared.i("Image change requested")
            
        case .editButtonTapped:
            state.showingEditView = true
            
        case .editViewDismissed:
            state.showingEditView = false
            
        case .filteredImageReceived(let image):
            state.selectedImage = image
            
        case .introduceChanged(let text):
            state.introduce = text
            
        case .priceChanged(let price):
            state.price = price
            
        case .saveButtonTapped:
            saveFilter()
            
        case .retryButtonTapped:
            state.errorMessage = nil
        }
    }
}

private extension MakeViewStore {
    func extractImageMetaData(image: UIImage, meta: PhotoMetadata?) {
        Task {
            let address = await meta?.getKoreanAddress()
            state.imageMetaData = meta
            state.address = address
        }
    }
    
    func saveFilter() {
        state.isLoading = true
        state.errorMessage = nil
        
        Task {
            do {
                let imageData = try ImageConverter.convertToData(
                    originalImage: state.selectedImage,
                    filteredImage: state.filteredImage
                )
                
                let result = try await useCase.files(imageData)
                
                state.isLoading = false
                state.saveResult = result.files
                state.showingSaveAlert = true
                GTLogger.shared.i("Filter save success: \(result.files)")
                
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                GTLogger.shared.w("Filter save failed: \(String(describing: state.errorMessage))")
            }
        }
    }
}

enum CategoryType: String, CaseIterable {
    case 푸드 = "푸드"
    case 인물 = "인물"
    case 풍경 = "풍경"
    case 야경 = "야경"
    case 별 = "별"
    
    var displayName: String {
        return self.rawValue
    }
}
