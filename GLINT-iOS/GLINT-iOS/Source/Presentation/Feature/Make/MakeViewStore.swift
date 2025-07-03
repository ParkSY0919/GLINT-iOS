//
//  MakeViewStore.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI
import PhotosUI

struct CreateFilterParams {
    let category: String
    let title: String
    let price: Int
    let description: String
    let files: [String]
    let photoMetadata: PhotoMetadataEntity?
    let filterValues: FilterValuesEntity
}

struct MakeViewState {
    var filterName: String = ""
    var selectedCategory: FilterCategoryItem.CategoryType? = nil
    var originImage: UIImage?
    var selectedImage: UIImage?
    var filteredImage: UIImage?
    var imageMetaData: PhotoMetadataEntity?
    var filterValues: FilterValuesEntity?
    var address: String?
    var introduce: String = ""
    var price: String = ""
    
    var isLoading: Bool = false
    var errorMessage: String?
//    var saveResult: [String]? = nil
}

enum MakeViewAction {
    case filterNameChanged(String)
    case categorySelected(FilterCategoryItem.CategoryType)
    case imageSelected(UIImage, PhotoMetadataEntity?)
    case imageChangeRequested
    case editButtonTapped(UIImage)
    case filteredImageReceived(UIImage)
    case introduceChanged(String)
    case priceChanged(String)
    case saveButtonTapped
    case retryButtonTapped
    case editCompleted(UIImage, FilterValuesEntity)
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
            state.originImage = image
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
            
        case .editCompleted(let filteredImage, let filterValues):
            state.filteredImage = filteredImage
            state.selectedImage = filteredImage
            state.filterValues = filterValues
            print(state.filterValues ?? "없지롱")
        }
    }
}

private extension MakeViewStore {
    func extractImageMetaData(image: UIImage, meta: PhotoMetadataEntity?) {
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
                
                let filesResult = try await useCase.files(imageData)
                
                guard let filterValues = state.filterValues else {
                    print("filterValues 가져오기 실패")
                    state.filterValues = state.filterValues!.setDefaultValues()
                    return
                }
                let request = CreateFilterRequest(
                    category: state.selectedCategory?.rawValue ?? "별",
                    title: /*state.filterName*/"케케",
                    price: /*Int(state.price) ?? 0*/100,
                    description: /*state.introduce*/"케케",
                    files: filesResult.files,
                    photoMetadata: nil,
                    filterValues: filterValues
                )
                
                let result = try await useCase.createFilter(request)
                print("result: \(result)")
                
                state.isLoading = false
                
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                GTLogger.shared.w("Filter save failed: \(String(describing: state.errorMessage))")
            }
        }
    }
    
    func setupEditCallback() {
        router.onPopData(UIImage.self, FilterValuesEntity.self) { [weak self] filteredImage, filterValues in
            self?.send(.editCompleted(filteredImage, filterValues))
        }
    }
}
