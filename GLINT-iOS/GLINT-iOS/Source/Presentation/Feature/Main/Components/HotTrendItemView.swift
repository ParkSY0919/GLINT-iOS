//
//  HotTrendItemView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/29/25.
//

import SwiftUI

struct HotTrendItemView: View {
    let trend: FilterEntity
    let isFocused: Bool
    let onTapped: () -> Void
    
    var body: some View {
        contentView
            .onTapGesture {
                onTapped()
            }
    }
}

private extension HotTrendItemView {
    var contentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            trendImageView()
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.2), radius: isFocused ? 8 : 4, x: 0, y: isFocused ? 4 : 2)
        .animation(.snappy(duration: 0.35), value: isFocused)
    }
    
    func trendImageView() -> some View {
        let imageUrlString = trend.filtered ?? ""
        return GTLazyImageView(urlString: imageUrlString) { image in
            GeometryReader { proxy in
                let global = proxy.frame(in: .global)
                let width = global.width
                image.aspectRatio(contentMode: .fill)
                    .frame(width: width, height: 300)
                    .clipped()
                    .brightness(isFocused ? 0 : -0.5)
                    .overlay(alignment: .topLeading) {
                        itemTitleOverlay
                    }
                    .overlay(alignment: .bottomTrailing) {
                        itemLikesOverlay
                    }
            }
        }
    }
    
    var itemTitleOverlay: some View {
        Text(trend.title ?? "")
            .font(.pointFont(.caption, size: 20))
            .lineLimit(1)
            .foregroundColor(.gray0)
            .padding(20)
            .opacity(isFocused ? 1 : 0.7)
    }
    
    var itemLikesOverlay: some View {
        HStack(spacing: 3) {
            Images.Detail.likeFill
            Text("\(trend.likeCount ?? 0 )")
        }
        .font(.pretendardFont(.caption_semi, size: 16))
        .foregroundColor(.white)
        .padding(EdgeInsets(top: 4, leading: 7, bottom: 4, trailing: 7))
        .padding(10)
        .opacity(isFocused ? 1 : 0.7)
    }
}
