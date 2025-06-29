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
            loadingIndicator
        }
    }
    
    var todayFilterSection: some View {
        TodayFilterView(
            todayFilter: store.state.todayFilter,
            onTryFilterTapped: { id in
                store.send(.tryFilterTapped(id: id))
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
            filter: store.state.todayArtist?.filters
        )
        .padding(.top, 30)
    }
    
    @ViewBuilder
    var loadingIndicator: some View {
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
}
