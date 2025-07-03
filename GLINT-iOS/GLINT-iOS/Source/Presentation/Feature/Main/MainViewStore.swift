//
//  MainViewStore.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/24/25.
//

import SwiftUI

struct MainViewState {
    var todayFilterData: FilterEntity?
    var hotTrendsData: [FilterEntity]?
    var todayArtistUser: ProfileEntity?
    var todayArtistFilter: [FilterEntity]?
    var isLoading: Bool = true
    var errorMessage: String?
}

enum MainViewAction {
    case viewAppeared                // 뷰가 나타났을 때
    case tryFilterTapped(id: String) // 오늘의 필터 사용 버튼 탭
    case hotTrendTapped(id: String) // 핫 트렌드 아이템 탭
    case todayArtistTapped(id: String) // 오늘의 작가 작업물 탭
    case categoryTapped(category: FilterCategoryItem)
    case retryButtonTapped          // 재시도 버튼 탭
}

@MainActor
@Observable
final class MainViewStore {
    private(set) var state = MainViewState()
    private let useCase: MainViewUseCase
    private let router: NavigationRouter<MainTabRoute>
    
    init(useCase: MainViewUseCase, router: NavigationRouter<MainTabRoute>) {
        self.useCase = useCase
        self.router = router
    }
    
    func send(_ action: MainViewAction) {
        switch action {
        case .viewAppeared:
            handleViewAppeared()
            
        case .tryFilterTapped(let id):
            handleToDetailView(id)
            
        case .hotTrendTapped(let id):
            handleToDetailView(id)
            
        case .todayArtistTapped(let id):
            handleToDetailView(id)
            
        case .categoryTapped(let category):
            handleToCategory(category)
            
        case .retryButtonTapped:
            handleRetryButtonTapped()
        }
    }
}

private extension MainViewStore {
    /// 뷰가 나타났을 때의 처리
    func handleViewAppeared() {
        // 이미 데이터가 있고 에러가 없으면 로딩하지 않음
        if hasDataAndNoError() { return }
        
        loadData()
    }
    
    /// filterID 따른 상세화면 이동
    func handleToDetailView(_ filterID: String) {
        router.push(.detail(id: filterID))
    }
    
    func handleToCategory(_ selectedCategory: FilterCategoryItem) {
        print("selectedCategory: \(selectedCategory)")
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
                let (f, h, aProfile, aFilter) = try await useCase.loadMainViewState()
                state = MainViewState(
                    todayFilterData: f,
                    hotTrendsData: h,
                    todayArtistUser: aProfile,
                    todayArtistFilter: aFilter,
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
        return state.todayFilterData != nil &&
        state.todayArtistUser != nil &&
        state.todayArtistFilter != nil &&
        state.hotTrendsData != nil &&
        state.errorMessage == nil
    }
}
