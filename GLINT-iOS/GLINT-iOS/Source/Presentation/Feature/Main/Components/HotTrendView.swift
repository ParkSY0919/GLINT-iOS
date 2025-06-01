//
//  HotTrendView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/22/25.
//

import SwiftUI

import NukeUI

// MARK: - HotTrendView
struct HotTrendView: View {
    @Binding var hotTrends: ResponseEntity.HotTrend?
    let router: NavigationRouter<MainTabRoute>
    let onHotTrendTapped: (String) -> Void
    
    @State private var centralTrendID: String?
    
    var body: some View {
        hotTrendContainer()
            .onAppear {
                // 뷰가 나타날 때 첫 번째 아이템에 포커스 적용
                if let firstTrend = hotTrends?.data.first {
                    centralTrendID = firstTrend.id
                }
            }
    }
    
    // MARK: - Container
    private func hotTrendContainer() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionTitle()
            trendsScrollView()
        }
    }
    
    // MARK: - Section Title
    private func sectionTitle() -> some View {
        Text("핫 트렌드")
            .font(.pretendardFont(.body_bold, size: 16))
            .foregroundStyle(.gray60)
            .padding(.leading, 20)
    }
    
    // MARK: - Trends Scroll View
    private func trendsScrollView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            trendsHorizontalStack()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $centralTrendID, anchor: .center)
        .frame(height: 300)
    }
    
    // MARK: - Horizontal Stack
    private func trendsHorizontalStack() -> some View {
        LazyHStack(spacing: 8) {
            if let data = hotTrends?.data {
                ForEach(data) { trend in
                    trendItem(for: trend)
                }
            }
            
        }
        .padding(.horizontal, screenWidthPadding())
        .scrollTargetLayout()
    }
    
    // MARK: - Trend Item
    private func trendItem(for trend: FilterEntity) -> some View {
        HotTrendItemView(
            trend: trend, 
            isFocused: trend.id == centralTrendID,
            onTapped: { onHotTrendTapped(trend.id) }
        )
        .frame(width: trendItemWidth())
        .id(trend.id)
    }
    
    // MARK: - Helper Functions
    private func trendItemWidth() -> CGFloat {
        UIScreen.main.bounds.width * 0.75
    }
    
    private func screenWidthPadding() -> CGFloat {
        UIScreen.main.bounds.width * 0.125
    }
}

//MARK: - Preview
//#Preview {
//    HotTrendView(trends: DummyFilterAppData.hotTrends, router: NavigationRouter<MainTabRoute>())
//        .preferredColorScheme(.dark)
//}

// MARK: - HotTrendItemView
struct HotTrendItemView: View {
    let trend: FilterEntity
    let isFocused: Bool
    let onTapped: () -> Void
    
    var body: some View {
        trendItemContainer()
            .onTapGesture {
                onTapped()
            }
    }
    
    // MARK: - Container
    private func trendItemContainer() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            trendImageView()
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.2), radius: isFocused ? 8 : 4, x: 0, y: isFocused ? 4 : 2)
        .animation(.snappy(duration: 0.35), value: isFocused)
    }
    
    // MARK: - Image View
    private func trendImageView() -> some View {
        let imageUrlString = trend.filtered ?? ""
        
        return LazyImage(url: URL(string: imageUrlString)) { state in
            lazyImageTransform(state) { image in
                GeometryReader { proxy in
                    let global = proxy.frame(in: .global)
                    let width = global.width
                    image.aspectRatio(contentMode: .fill)
                        .frame(width: width, height: 300)
                        .clipped()
                        .brightness(isFocused ? 0 : -0.5)
                        .overlay(alignment: .topLeading) {
                            trendTitleOverlay()
                        }
                        .overlay(alignment: .bottomTrailing) {
                            trendLikesOverlay()
                        }
                }
            }
        }
    }
    
    // MARK: - Title Overlay
    private func trendTitleOverlay() -> some View {
        Text(trend.title)
            .font(.pointFont(.caption, size: 20))
            .lineLimit(1)
            .foregroundColor(.gray0)
            .padding(20)
            .opacity(isFocused ? 1 : 0.7)
    }
    
    // MARK: - Likes Overlay
    private func trendLikesOverlay() -> some View {
        HStack(spacing: 3) {
            likesIcon()
            likesCount()
        }
        .font(.pretendardFont(.caption_semi, size: 16))
        .foregroundColor(.white)
        .padding(EdgeInsets(top: 4, leading: 7, bottom: 4, trailing: 7))
        .padding(10)
        .opacity(isFocused ? 1 : 0.7)
    }
    
    private func likesIcon() -> some View {
        Image(systemName: "heart.fill")
    }
    
    private func likesCount() -> some View {
        Text("\(trend.likeCount)")
    }
}
