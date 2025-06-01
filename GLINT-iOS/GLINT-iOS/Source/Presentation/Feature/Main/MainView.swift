//
//  MainView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/22/25.
//

import SwiftUI

struct MainView: View {
    let router: NavigationRouter<MainTabRoute>
    let store: MainViewStore  // @State 제거! 외부에서 주입받음
    
    var body: some View {
        Group {
            if store.state.isLoading && !store.state.hasLoadedOnce {
                StateViewBuilder.loadingView()
            } else if let errorMessage = store.state.errorMessage, !store.state.hasLoadedOnce {
                StateViewBuilder.errorView(
                    errorMessage: errorMessage
                ) {
                    store.send(.retryButtonTapped)
                }
            } else {
                contentView
            }
        }
        .ignoresSafeArea(.all, edges: .top)
        .background(.gray100)
        .onAppear {
            store.send(.viewAppeared)
        }
        .animation(.easeInOut(duration: 0.3), value: store.state.isLoading && !store.state.hasLoadedOnce)
        .sensoryFeedback(.impact(weight: .light), trigger: store.state.errorMessage)
    }
}

// MARK: - Views
private extension MainView {
    var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                TodayFilterView(
                    todayFilter: .constant(store.state.todayFilter),
                    router: router,
                    onTryFilterTapped: { store.send(.tryFilterTapped) }
                )
                
                BannerView(
                    items: DummyFilterAppData.bannerItems,
                    router: router
                )
                .padding(.top, 20)
                
                HotTrendView(
                    hotTrends: .constant(store.state.hotTrends),
                    router: router,
                    onHotTrendTapped: { id in
                        store.send(.hotTrendTapped(id: id))
                    }
                )
                .padding(.top, 30)
                
                TodayArtistView(
                    todayArtist: .constant(store.state.todayArtist),
                    router: router
                )
                .padding(.top, 30)
            }
            .padding(.bottom, 20)
            
            // 백그라운드에서 로딩 중일 때 표시할 인디케이터
            if store.state.isLoading && store.state.hasLoadedOnce {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(0.8)
                        .padding()
                    Spacer()
                }
            }
        }
        .detectScroll()
        .scrollContentBackground(.hidden)
        .contentMargins(.top, 0, for: .scrollContent)
    }
}
