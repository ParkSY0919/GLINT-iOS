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
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            content
                .onViewDidLoad(perform: {
                    store.send(.viewAppeared)
                })
        }
        .ignoresSafeArea(.all)
        .onAppear {
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
    
    var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.pinterestDarkBg,
                Color.pinterestDarkSurface,
                animateGradient ? Color.pinterestRedSoft.opacity(0.3) : Color.pinterestDarkBg
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea(.all)
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
        VStack(alignment: .leading, spacing: 24) {
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
        VStack(alignment: .leading, spacing: 16) {
            // SafeArea 아래에 위치하도록 패딩 추가
            Spacer()
                .frame(height: 0)
                .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44)
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.gradientStart, .gradientMid, .gradientEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: .pinterestRed.opacity(0.4), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(Strings.Community.title)
                        .font(.pretendardFont(.title_bold, size: 28))
                        .foregroundColor(.pinterestTextPrimary)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    Text(Strings.Community.subtitle)
                        .font(.pretendardFont(.body_medium, size: 16))
                        .foregroundColor(.pinterestTextSecondary)
                }
                
                Spacer()
            }
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
        } else {
            StateViewBuilder.emptyStateView(message: Strings.Community.Error.loadFailed)
        }
    }
}
