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
    
    enum Action {
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
    
    var state = State()
    private var makeViewUseCase: MakeViewUseCase?
    
    func send(_ action: Action) {
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
    
    private func extractImageMetaData(image: UIImage, meta: PhotoMetadata?) {
        Task {
            let address = await meta?.getKoreanAddress()
            state.imageMetaData = meta
            state.address = address
        }
    }
    
    private func saveFilter() {
        guard let originalImage = state.selectedImage,
              let makeViewUseCase = makeViewUseCase else {
            state.errorMessage = "이미지 또는 UseCase가 없습니다."
            return
        }
        
        state.isLoading = true
        state.errorMessage = nil
        
        Task {
            do {
                // 원본 이미지와 필터된 이미지를 base64로 변환
                guard let originalData = originalImage.jpegData(compressionQuality: 0.8) else {
                    throw NSError(domain: "ImageConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "원본 이미지 변환 실패"])
                }
                
                let filteredData: Data
                if let filteredImage = state.filteredImage {
                    guard let data = filteredImage.jpegData(compressionQuality: 0.8) else {
                        throw NSError(domain: "ImageConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "필터 이미지 변환 실패"])
                    }
                    filteredData = data
                } else {
                    filteredData = originalData  // 필터가 없으면 원본 사용
                }
                
                let originalBase64 = originalData.base64EncodedString()
                let filteredBase64 = filteredData.base64EncodedString()
                
                GTLogger.shared.i("API 호출 시작 - 원본: \(originalData.count) bytes, 필터: \(filteredData.count) bytes")
                
                let result = try await makeViewUseCase.files([originalData, filteredData])
                
                await MainActor.run {
                    state.isLoading = false
                    state.saveResult = result.files
                    state.showingSaveAlert = true
                    GTLogger.shared.i("Filter save success: \(result.files)")
                }
            } catch {
                await MainActor.run {
                    state.isLoading = false
                    state.errorMessage = error.localizedDescription
                    GTLogger.shared.w("Filter save failed: \(error)")
                }
            }
        }
    }
}

// UseCase 설정을 위한 메서드 추가
extension MakeViewStore {
    func setUseCase(_ useCase: MakeViewUseCase) {
        self.makeViewUseCase = useCase
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
