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
    let filterEntities: [FilterEntity]?
    let onHotTrendTapped: (String) -> Void
//    private let imagePrefetcher = ImagePrefetcher()
    
    @State
    private var centralTrendID: String?
    
    var body: some View {
        if let filterEntities {
            contentView
                .onAppear {
                    centralTrendID = filterEntities.first?.id
                }
        } else {
            StateViewBuilder.emptyStateView(message: Strings.Main.Error.hotTrendLoadFailed)
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
        Text(Strings.Main.hotTrend)
            .font(.pretendardFont(.body_bold, size: 16))
            .foregroundStyle(.gray60)
            .padding(.leading, 20)
    }
    
    var hotTrendScrollContentSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            if let data = filterEntities {
                trendsHorizontalStack(data: data)
            }
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $centralTrendID, anchor: .center)
        .frame(height: 300)
        .clipped()
    }
    
    func trendsHorizontalStack(data: [FilterEntity]) -> some View {
        LazyHStack(spacing: 8) {
            ForEach(data) { trend in
                trendItem(for: trend)
                    .prefetchImageIfPresent(trend.filtered)
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
