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
    var showCreateAlert: Bool = false
    var createFilterTitle: String?
    var createFilterId: String?
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
    case createAlertDismissed
}

@MainActor
@Observable
final class MakeViewStore {
    private(set) var state = MakeViewState()
    private let useCase: MakeViewUseCase
    private let router: NavigationRouter<MakeTabRoute>
    private weak var tabBarViewModel: TabBarViewModel?
    
    init(useCase: MakeViewUseCase, router: NavigationRouter<MakeTabRoute>) {
        self.useCase = useCase
        self.router = router
        self.tabBarViewModel = nil
        
        setupEditCallback()
    }
    
    /// TabBarViewModel 참조를 설정 (초기화 후 호출)
    func setTabBarViewModel(_ tabBarViewModel: TabBarViewModel) {
        self.tabBarViewModel = tabBarViewModel
    }
    
    /// Make 뷰 상태를 초기화
    func resetState() {
        state = MakeViewState()
        // 상태 초기화 후 edit 콜백을 다시 등록
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
            GTLogger.shared.i(Strings.Make.Log.imageChangeRequested)
            
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
            print(state.filterValues ?? Strings.Make.Log.filterValuesNotFound)
            
        case .createAlertDismissed:
            handleCreateAlertDismissed()
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
                    originalImage: state.originImage,
                    filteredImage: state.filteredImage
                )
                
                let uploadFilesResult = try await useCase.files(imageData)
                
                guard let filterValues = state.filterValues else {
                    print(Strings.Make.Error.filterValuesFailed)
//                    state.filterValues = state.filterValues!.setDefaultValues()
                    return
                }
                let request = CreateFilterRequest(
                    category: state.selectedCategory?.rawValue ?? "별",
                    title: state.filterName,
                    price: Int(state.price) ?? 0,
                    description: state.introduce,
                    files: uploadFilesResult,
                    photoMetadata: nil,
                    filterValues: filterValues
                )
                
                let result = try await useCase.createFilter(request)
                print("result: \(result)")
                state.createFilterTitle = result.title
                state.createFilterId = result.filterID
                state.showCreateAlert = true
                
                state.isLoading = false
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                GTLogger.shared.w("\(Strings.Make.Error.filterSaveFailed): \(String(describing: state.errorMessage))")
            }
        }
    }
    
    func setupEditCallback() {
        router.onPopData(UIImage.self, FilterValuesEntity.self) { [weak self] filteredImage, filterValues in
            self?.send(.editCompleted(filteredImage, filterValues))
        }
    }
    
    func handleCreateAlertDismissed() {
        state.showCreateAlert = false
        
        // 생성된 필터의 ID가 있으면 mainRouter를 통해 detailView로 이동
        if let filterId = state.createFilterId {
            tabBarViewModel?.navigateToDetailFromMake(filterId: filterId)
        }
    }
}
