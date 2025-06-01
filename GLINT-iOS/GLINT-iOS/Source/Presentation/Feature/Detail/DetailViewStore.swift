//
//  DetailViewStore.swift
//  GLINT-iOS
//
//  Created by 박신영 on 12/25/24.
//

import SwiftUI

// MARK: - State
struct DetailViewState {
    var filterDetail: FilterDetailEntity?
    var isLoading: Bool = true
    var errorMessage: String?
    var hasLoadedOnce: Bool = false
    var isPurchased: Bool = false // 필터 구매 여부
    var sliderPosition: CGFloat = 0.5 // Before/After 슬라이더 위치 (0.0 ~ 1.0)
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
    init() {
        // TODO: 실제 UseCase 주입
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
                // TODO: 실제 API 호출 구현
                // 임시 데이터로 대체
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 지연
                
                state.filterDetail = createMockFilterDetail()
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
    
    /// 임시 데이터 생성
    func createMockFilterDetail() -> FilterDetailEntity {
        return FilterDetailEntity(
            id: filterId,
            title: "청록새록",
            price: 2000,
            downloadCount: 2400,
            likeCount: 800,
            originalImageURL: "https://picsum.photos/400/600?random=1",
            filteredImageURL: "https://picsum.photos/400/600?random=2",
            deviceInfo: "Apple iPhone 15 Pro",
            cameraInfo: "와이드 카메라 - 26 mm ƒ/1.5 ISO 400",
            imageSize: "12MP • 3024 × 4032 • 2.2MB",
            locationInfo: "서울 영등포구 선유로 3길 30",
            author: AuthorEntity(
                userID: "author1",
                nick: "SESAC YOON",
                name: "윤새싹",
                introduction: "섬세한 정서를 담아내는 새싹작가",
                description: "자연 아래 돋아나는 새싹처럼,\n맑고 투명한 빛을 담은 자연 감성 필터입니다.\n너무 과하지 않게, 부드러운 색감으로 분위기를 살려줍니다.\n새로운 시작, 순수한 감정을 담고 싶을 때 이 필터를 사용해보세요.",
                profileImage: "https://picsum.photos/72/72?random=3",
                hashTags: ["#섬세함", "#자연", "#미니멀"]
            ),
            filterPresets: [
                FilterPresetEntity(id: "1", name: "밝기", value: "-4.0", icon: "sun.max"),
                FilterPresetEntity(id: "2", name: "대비", value: "1.5", icon: "circle.lefthalf.filled"),
                FilterPresetEntity(id: "3", name: "채도", value: "2.5", icon: "drop"),
                FilterPresetEntity(id: "4", name: "색온도", value: "0.1", icon: "thermometer"),
                FilterPresetEntity(id: "5", name: "하이라이트", value: "-4.0", icon: "mountain.2"),
                FilterPresetEntity(id: "6", name: "노출", value: "10.5", icon: "camera.aperture")
            ]
        )
    }
}

// MARK: - Filter Detail Entity
struct FilterDetailEntity {
    let id: String
    let title: String
    let price: Int
    let downloadCount: Int
    let likeCount: Int
    let originalImageURL: String
    let filteredImageURL: String
    let deviceInfo: String
    let cameraInfo: String
    let imageSize: String
    let locationInfo: String?
    let author: AuthorEntity
    let filterPresets: [FilterPresetEntity]
}

// MARK: - Filter Preset Entity
struct FilterPresetEntity: Identifiable {
    let id: String
    let name: String
    let value: String
    let icon: String
} 
