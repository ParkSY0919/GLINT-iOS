//
//  CommunityViewStore.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/26/25.
//

import SwiftUI

struct CommunityViewState {
    var communityItems: [FilterEntity]?
    var isLoading: Bool = true
    var errorMessage: String?
}

enum CommunityViewAction {
    case viewAppeared
    case communityItemTapped(id: String)
    case retryButtonTapped
}

@MainActor
@Observable
final class CommunityViewStore {
    private(set) var state = CommunityViewState()
    private let useCase: CommunityViewUseCase
    private let router: NavigationRouter<CommunityTabRoute>
    private weak var tabBarViewModel: TabBarViewModel?
    
    init(useCase: CommunityViewUseCase, router: NavigationRouter<CommunityTabRoute>) {
        self.useCase = useCase
        self.router = router
    }
    
    /// TabBarViewModel 참조 설정
    func setTabBarViewModel(_ viewModel: TabBarViewModel) {
        self.tabBarViewModel = viewModel
    }
    
    func send(_ action: CommunityViewAction) {
        switch action {
        case .viewAppeared:
            handleViewAppeared()
            
        case .communityItemTapped(let id):
            handleToDetailView(id)
            
        case .retryButtonTapped:
            handleRetryButtonTapped()
        }
    }
    
    /// 상태 초기화
    func resetState() {
        state = CommunityViewState()
    }
}

private extension CommunityViewStore {
    /// 뷰가 나타났을 때의 처리
    func handleViewAppeared() {
        // 이미 데이터가 있고 에러가 없으면 로딩하지 않음
        if hasDataAndNoError() { return }
        
        loadData()
    }
    
    /// filterID 따른 상세화면 이동 (TabBarViewModel을 통한 cross-tab navigation)
    func handleToDetailView(_ filterID: String) {
        tabBarViewModel?.navigateToDetailFromCommunity(filterId: filterID)
    }
    
    /// 재시도 버튼 탭 처리
    func handleRetryButtonTapped() {
        state.errorMessage = nil
        state.isLoading = true
        loadData()
    }
    
    /// 서버에서 데이터를 비동기로 로드
    func loadData() {
        state.isLoading = true
        state.errorMessage = nil
        
        Task {
            do {
                let communityItems = try await useCase.loadCommunityItems()
                state = CommunityViewState(
                    communityItems: communityItems,
                    isLoading: false,
                    errorMessage: nil
                )
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
            }
        }
    }
    
    /// 데이터가 있고 에러가 없는지 확인
    func hasDataAndNoError() -> Bool {
        return state.communityItems != nil &&
        state.errorMessage == nil
    }
}