//
//  DetailViewStore.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import SwiftUI

// MARK: - State
struct DetailViewState {
    var filterData: FilterModel?
    var userInfoData: UserInfoModel?
    var photoMetaData: PhotoMetadataModel?
    var filterPresetsData: FilterPresetsModel?
    
    var address: String?
    
    var isLoading: Bool = true
    var errorMessage: String?
    var hasLoadedOnce: Bool = false
    var isPurchased: Bool = false // 필터 구매 여부
    var sliderPosition: CGFloat = 0.5
}

// MARK: - Action
enum DetailViewAction {
    case viewAppeared(id: String)
    case sliderPositionChanged(CGFloat)
    case purchaseButtonTapped
    case sendMessageTapped
    case retryButtonTapped
}

@Observable
final class DetailViewStore {
    private(set) var state = DetailViewState()
    
    // 필터 ID
    private var filterId: String = ""
    
    /// 의존성 주입을 통한 초기화
    private let filterDetailUseCase: DetailViewUseCase
    
    init(filterDetailUseCase: DetailViewUseCase) {
        self.filterDetailUseCase = filterDetailUseCase
    }
    
    /// - Parameter action: 처리할 액션
    @MainActor
    func send(_ action: DetailViewAction) {
        switch action {
        case .viewAppeared(let id):
            handleViewAppeared(id: id)
            
        case .sliderPositionChanged(let position):
            handleSliderPositionChanged(position: position)
            
        case .purchaseButtonTapped:
            handlePurchaseButtonTapped()
            
        case .sendMessageTapped:
            handleSendMessageTapped()
            
        case .retryButtonTapped:
            handleRetryButtonTapped()
        }
    }
}

// MARK: - Private Action Handlers
@MainActor
private extension DetailViewStore {
    /// 뷰가 나타났을 때의 처리
    func handleViewAppeared(id: String) {
        filterId = id
        if !state.hasLoadedOnce {
            loadFilterDetail()
        }
    }
    
    /// 슬라이더 위치 변경 처리
    func handleSliderPositionChanged(position: CGFloat) {
        state.sliderPosition = max(0.0, min(1.0, position))
    }
    
    /// 구매 버튼 탭 처리
    func handlePurchaseButtonTapped() {
        print("구매 버튼 탭됨")
        // TODO: 실제 구매 로직 구현
        state.isPurchased = true
    }
    
    /// 메시지 보내기 버튼 탭 처리
    func handleSendMessageTapped() {
        print("메시지 보내기 버튼 탭됨")
        // TODO: 메시지 화면으로 네비게이션
    }
    
    /// 재시도 버튼 탭 처리
    func handleRetryButtonTapped() {
        state.errorMessage = nil
        state.isLoading = true
        loadFilterDetail()
    }
    
    /// 필터 상세 정보 로드
    func loadFilterDetail() {
        state.isLoading = true
        state.errorMessage = nil
        
        Task {
            do {
                async let filterDetail = filterDetailUseCase.filterDetail(filterId)
                let filterData = try await filterDetail
                
                state.filterData = filterData.filter
                state.userInfoData = filterData.author
                state.photoMetaData = filterData.photoMetadata
                state.filterPresetsData = filterData.filterValues
                state.address = await filterData.photoMetadata.getKoreanAddress()
                
                state.isPurchased = filterData.filter.isDownloaded ?? false
                state.isLoading = false
                state.hasLoadedOnce = true
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                if !state.hasLoadedOnce {
                    state.hasLoadedOnce = true
                }
            }
        }
    }
}
