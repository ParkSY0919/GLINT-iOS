//
//  MainViewStore.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/24/25.
//

import SwiftUI

// MARK: - State
struct MainViewState {
    var todayFilter: ResponseEntity.TodayFilter?
    var todayArtist: ResponseEntity.TodayAuthor?
    var hotTrends: ResponseEntity.HotTrend?
    var isLoading: Bool = true
    var errorMessage: String?
    var hasLoadedOnce: Bool = false  // 한 번이라도 로드했는지 추적
}

// MARK: - Action
enum MainViewAction {
    case viewAppeared      // 뷰가 나타났을 때
    case tryFilterTapped   // 오늘의 필터 사용 버튼 탭
    case retryButtonTapped // 재시도 버튼 탭
}

@Observable
final class MainViewStore {
    private(set) var state = MainViewState()
    
    // UseCase 의존성 주입
    private let todayPickUseCase: TodayPickUseCase
    
    // 캐시 만료 시간 (5분)
    private let cacheExpirationTime: TimeInterval = 300
    
    /// 의존성 주입을 통한 초기화
    init(todayPickUseCase: TodayPickUseCase) {
        self.todayPickUseCase = todayPickUseCase
    }
    
    /// - Parameter action: 처리할 액션
    @MainActor
    func send(_ action: MainViewAction) {
        switch action {
        case .viewAppeared:
            handleViewAppeared()
            
        case .tryFilterTapped:
            handleTryFilterTapped()
            
        case .retryButtonTapped:
            handleRetryButtonTapped()
        }
    }
}

// MARK: - Private Action Handlers
@MainActor
private extension MainViewStore {
    /// 뷰가 나타났을 때의 처리
    func handleViewAppeared() {
        // 이미 데이터가 있고 에러가 없으면 로딩하지 않음
        if hasDataAndNoError() {
            
            return
        }
        
        print("state.hasLoadedOnce: \(state.hasLoadedOnce)")
        // 처음 로드이거나 캐시가 만료된 경우에만 로딩
        if !state.hasLoadedOnce {
            loadData()
        }
    }
    
    /// 필터 사용 버튼 탭 처리
    func handleTryFilterTapped() {
        print("오늘의 필터 사용해보기 버튼 탭됨")
        // TODO: 필터 사용 화면으로 네비게이션 로직 구현
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
                // TodayPickUseCase를 사용해서 병렬로 데이터 로드
                async let todayAuthor = todayPickUseCase.todayAuthor()
                async let todayFilter = todayPickUseCase.todayFilter()
                async let todayHotTrend = todayPickUseCase.hotTrend()
                
                let (author, filter, hotTrend) = try await (todayAuthor, todayFilter, todayHotTrend)
                
                state.todayFilter = filter
                state.todayArtist = author
                state.hotTrends = hotTrend
                state.isLoading = false
                state.hasLoadedOnce = true
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                // 에러가 발생해도 hasLoadedOnce는 true로 유지 (이전 데이터 보존)
                if !state.hasLoadedOnce {
                    state.hasLoadedOnce = true
                }
            }
        }
    }
    
    /// 데이터가 있고 에러가 없는지 확인
    func hasDataAndNoError() -> Bool {
        return state.todayFilter != nil &&
               state.todayArtist != nil &&
               state.hotTrends != nil &&
               state.errorMessage == nil
    }
}
