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
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(price.formatted()) \(Strings.Detail.coin)")
                    .font(.pointFont(.title, size: 32))
                    .foregroundColor(.gray0)
                
                HStack(spacing: 12) {
                    downloadCountBox
                    likeCountBox
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
}

private extension PriceSectionView {
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
