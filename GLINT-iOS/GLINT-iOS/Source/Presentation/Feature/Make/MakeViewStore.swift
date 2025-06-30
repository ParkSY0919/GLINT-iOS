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
    var selectedCategory: FilterCategoryItem.CategoryType? = nil
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
    case categorySelected(FilterCategoryItem.CategoryType)
    case imageSelected(UIImage, PhotoMetadata?)
    case imageChangeRequested
    case editButtonTapped(UIImage)
    case filteredImageReceived(UIImage)
    case introduceChanged(String)
    case priceChanged(String)
    case saveButtonTapped
    case retryButtonTapped
    case editCompleted(UIImage)
}

@MainActor
@Observable
final class MakeViewStore {
    private(set) var state = MakeViewState()
    private let useCase: MakeViewUseCase
    private let router: NavigationRouter<MakeTabRoute>
    
    init(useCase: MakeViewUseCase, router: NavigationRouter<MakeTabRoute>) {
        self.useCase = useCase
        self.router = router
        
        setupEditCallback()
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
            
        case .editButtonTapped(let image):
            router.push(.edit(originImage: image))
            
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
            
        case .editCompleted(let filteredImage):
            state.selectedImage = filteredImage
            state.filteredImage = filteredImage
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
    
    func setupEditCallback() {
        router.onPopData(UIImage.self) { [weak self] filteredImage in
            self?.send(.editCompleted(filteredImage))
        }
    }
}
