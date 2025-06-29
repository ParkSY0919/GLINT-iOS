//
//  HotTrendView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/22/25.
//

import SwiftUI

import Nuke
import NukeUI

struct HotTrendView: View {
    let hotTrends: HotTrendResponse?
    let onHotTrendTapped: (String) -> Void
    private let imagePrefetcher = ImagePrefetcher()
    
    @State
    private var centralTrendID: String?
    
    var body: some View {
        if let hotTrends {
            contentView
                .onAppear {
                    centralTrendID = hotTrends.data.first?.filterID
                }
        } else {
            StateViewBuilder.emptyStateView(message: "핫 트렌드를 불러올 수 없습니다.")
        }
    }
}

private extension HotTrendView {
    var contentView: some View {
        VStack(alignment: .leading, spacing: 20) {
            hotTrendTitleSection
            hotTrendScrollContentSection
        }
    }
    
    var hotTrendTitleSection: some View {
        Text("핫 트렌드")
            .font(.pretendardFont(.body_bold, size: 16))
            .foregroundStyle(.gray60)
            .padding(.leading, 20)
    }
    
    var hotTrendScrollContentSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            if let data = hotTrends?.data {
                trendsHorizontalStack(data: data)
            }
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $centralTrendID, anchor: .center)
        .frame(height: 300)
        .clipped()
    }
    
    func trendsHorizontalStack(data: [FilterSummary]) -> some View {
        LazyHStack(spacing: 8) {
            ForEach(data) { trend in
                let entity = trend.toEntity()
                trendItem(for: entity)
                    .prefetchImageIfPresent(entity.filtered)
            }
        }
        .padding(.horizontal, screenWidthPadding)
        .scrollTargetLayout()
    }
    
    func trendItem(for trend: FilterEntity) -> some View {
        HotTrendItemView(
            trend: trend,
            isFocused: trend.id == centralTrendID,
            onTapped: { onHotTrendTapped(trend.id) }
        )
        .frame(width: trendItemWidth)
        .id(trend.id)
    }
    
    var trendItemWidth: CGFloat {
        return UIScreen.main.bounds.width * 0.75
    }
    
    var screenWidthPadding: CGFloat {
        return UIScreen.main.bounds.width * 0.125
    }
}
