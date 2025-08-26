//
//  CommunityView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/26/25.
//

import SwiftUI

struct CommunityView: View {
    @Environment(CommunityViewStore.self)
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

private extension CommunityView {
    var mainContentView: some View {
        ScrollView(showsIndicators: false) {
            scrollContent
        }
        .detectScroll()
        .scrollContentBackground(.hidden)
    }
    
    var scrollContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            communityHeaderSection
            communityItemsSection
        }
        .padding(.bottom, 20)
        .overlay(alignment: .bottom) {
            if store.state.isLoading {
                StateViewBuilder.loadingIndicator()
            }
        }
    }
    
    var communityHeaderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Strings.Community.title)
                .font(.pretendardFont(.body_bold, size: 24))
                .foregroundStyle(.gray75)
                .padding(.top, 20)
            
            Text(Strings.Community.subtitle)
                .font(.pretendardFont(.body_medium, size: 14))
                .foregroundStyle(.gray45)
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    var communityItemsSection: some View {
        if let items = store.state.communityItems {
            CommunityItemsGridView(
                items: items,
                onItemTapped: { id in
                    store.send(.communityItemTapped(id: id))
                }
            )
            .padding(.top, 20)
        } else {
            StateViewBuilder.emptyStateView(message: Strings.Community.Error.loadFailed)
        }
    }
}
