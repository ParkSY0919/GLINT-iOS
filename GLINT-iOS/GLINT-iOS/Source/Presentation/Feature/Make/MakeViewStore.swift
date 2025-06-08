//
//  MakeViewStore.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI
import PhotosUI

@Observable
final class MakeViewStore {
    struct State {
        var filterName: String = ""
        var selectedCategory: CategoryType? = nil
        var selectedImage: UIImage?
        var imageMetaData: PhotoMetadataModel?
        var address: String?
        var introduce: String = ""
        var price: String = ""
        var showingEditView: Bool = false
        
        var isLoading: Bool = false
        var errorMessage: String?
    }
    
    enum Action {
        case filterNameChanged(String)
        case categorySelected(CategoryType)
        case imageSelected(UIImage, PhotoMetadataModel?)
        case imageChangeRequested
        case editButtonTapped
        case editViewDismissed
        case filteredImageReceived(UIImage)
        case introduceChanged(String)
        case priceChanged(String)
        case saveButtonTapped
        case retryButtonTapped
    }
    
    var state = State()
    
    func send(_ action: Action) {
        switch action {
        case .filterNameChanged(let name):
            state.filterName = name
            
        case .categorySelected(let category):
            state.selectedCategory = category
            
        case .imageSelected(let image, let metadata):
            state.selectedImage = image
            // TODO: 이미지 메타데이터 추출 로직 구현
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
    
    private func extractImageMetaData(image: UIImage, meta: PhotoMetadataModel?) {
        Task {
            let address = await meta?.getKoreanAddress()
            state.imageMetaData = meta
            state.address = address
        }
    }
    
    private func saveFilter() {
        state.isLoading = true
        
        // TODO: 필터 저장 API 호출 로직 구현
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.state.isLoading = false
            GTLogger.shared.i("Filter saved successfully")
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

struct PhotoMetaData {
    let camera: String
    let metaData: [String]
    let latitude: Double?
    let longitude: Double?
} 
