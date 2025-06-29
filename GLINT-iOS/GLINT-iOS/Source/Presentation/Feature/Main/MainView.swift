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
            .ignoresSafeArea(.all, edges: .top)
            .background(.gray100)
            .onAppear {
                store.send(.viewAppeared)
            }
            .animation(.easeInOut(duration: 0.3), value: store.state.isLoading && !store.state.hasLoadedOnce)
            .sensoryFeedback(.impact(weight: .light), trigger: store.state.errorMessage)
    }
    
    @ViewBuilder
    private var content: some View {
        switch (store.state.isLoading, store.state.hasLoadedOnce, store.state.errorMessage) {
        case (true, false, _):
            StateViewBuilder.loadingView()
        case (_, false, let error?) where !error.isEmpty:
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
            if store.state.isLoading && store.state.hasLoadedOnce {
                StateViewBuilder.loadingIndicator()
            }
        }
    }
    
    var todayFilterSection: some View {
        TodayFilterView(
            filterEntity: store.state.todayFilter?.toFilterEntity(),
            onTryFilterTapped: { id in
                store.send(.tryFilterTapped(id: id))
            },
            onTapCategory: { category in
                store.send(.categoryTapped(category: category))
            }
        )
    }
    
    var bannerSection: some View {
        let bannerItems: [BannerItem] = (1...3).map { BannerItem(imageName: "banner_image_\($0)") }
        return BannerView(items: bannerItems)
            .padding(.top, 20)
    }
    
    var hotTrendSection: some View {
        HotTrendView(
            hotTrends: store.state.hotTrends,
            onHotTrendTapped: { id in
                store.send(.hotTrendTapped(id: id))
            }
        )
        .padding(.top, 30)
    }
    
    var todayArtistSection: some View {
        TodayArtistView(
            author: store.state.todayArtist?.author,
            filter: store.state.todayArtist?.filters,
            onTapWorksItem: { id in
                store.send(.todayArtistTapped(id: id))
            }
        )
        .padding(.top, 30)
    }
}
