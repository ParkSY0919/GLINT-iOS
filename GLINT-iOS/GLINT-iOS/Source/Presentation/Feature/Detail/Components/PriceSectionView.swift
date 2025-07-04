//
//  PriceSectionView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

struct PriceSectionView: View {
    let price: Int
    let buyerCount: Int
    let likeCount: Int
    
    var body: some View {
        contentView
            .padding(.horizontal, 20)
            .padding(.top, 24)
    }
}

private extension PriceSectionView {
    var contentView: some View {
        HStack(alignment: .top, spacing: 16) {
            priceInfoSection
            Spacer()
        }
    }
    
    var priceInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            priceTextSection
            statisticsSection
        }
    }
    
    var priceTextSection: some View {
        Text("\(price.formatted()) \(Strings.Detail.coin)")
            .font(.pointFont(.title, size: 32))
            .foregroundColor(.gray0)
    }
    
    var statisticsSection: some View {
        HStack(spacing: 12) {
            downloadCountBox
            likeCountBox
        }
    }
    
    var downloadCountBox: some View {
        VStack(spacing: 4) {
            Text(Strings.Detail.download)
                .font(.pretendardFont(.caption, size: 12))
                .foregroundColor(.gray60)
            
            Text("\(formatCount(buyerCount))+")
                .font(.pretendardFont(.body_bold, size: 14))
                .foregroundColor(.gray0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.gray90)
        .clipRectangle(8)
    }
    
    var likeCountBox: some View {
        VStack(spacing: 4) {
            Text(Strings.Detail.like)
                .font(.pretendardFont(.caption, size: 12))
                .foregroundColor(.gray60)
            
            Text("\(formatCount(likeCount))")
                .font(.pretendardFont(.body_bold, size: 14))
                .foregroundColor(.gray0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.gray90)
        .clipRectangle(8)
    }
    
    func formatCount(_ count: Int) -> String {
        if count >= 1000 {
            return "\(count / 1000)k"
        }
        return "\(count)"
    }
} 
