//
//  MainView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/22/25.
//

import SwiftUI

struct MainView: View {
    @Environment(MainViewStore.self)
    private var store
    
    var body: some View {
        content
            .appScreenStyle(
                ignoresSafeArea: true,
                safeAreaEdges: .top,
                isLoading: store.state.isLoading,
                errorMessage: store.state.errorMessage
            )
            .onViewDidLoad(perform: {
                store.send(.viewAppeared)
            })
    }
    
    @ViewBuilder
    private var content: some View {
        switch (store.state.isLoading, store.state.errorMessage) {
        case (true, _):
            StateViewBuilder.loadingView()
        case (_, let error?) where !error.isEmpty:
            StateViewBuilder.errorView(errorMessage: error) {
                store.send(.retryButtonTapped)
            }
        default:
            mainContentView
        }
    }
}

private extension MainView {
    var mainContentView: some View {
        ScrollView(showsIndicators: false) {
            scrollContent
        }
        .detectScroll()
        .scrollContentBackground(.hidden)
    }
    
    var scrollContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            todayFilterSection
            bannerSection
            hotTrendSection
            todayArtistSection
        }
        .padding(.bottom, 20)
        .overlay(alignment: .bottom) {
            if store.state.isLoading {
                StateViewBuilder.loadingIndicator()
            }
        }
    }
    
    var todayFilterSection: some View {
        TodayFilterView(
            filterEntity: store.state.todayFilterData,
            onTryFilterTapped: { id in
                store.send(.tryFilterTapped(id: id))
            },
            onTapCategory: { category in
                store.send(.categoryTapped(category: category))
            }
        )
    }
    
    var bannerSection: some View {
        BannerView(bannerEntities: store.state.bannerList) {
            store.send(.attendanceTapped)
        }
        .padding(.top, 20)
    }
    
    var hotTrendSection: some View {
        HotTrendView(
            filterEntities: store.state.hotTrendsData,
            onHotTrendTapped: { id in
                store.send(.hotTrendTapped(id: id))
            }
        )
        .padding(.top, 30)
    }
    
    var todayArtistSection: some View {
        TodayArtistView(
            author: store.state.todayArtistUser,
            filters: store.state.todayArtistFilter,
            onTapWorksItem: { id in
                store.send(.todayArtistTapped(id: id))
            }
        )
        .padding(.top, 30)
    }
}
