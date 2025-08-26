//
//  CommunityItemView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/26/25.
//

import SwiftUI
import Nuke
import NukeUI

struct CommunityItemView: View {
    let item: FilterEntity
    let onTapped: () -> Void
    
    var body: some View {
        Button(action: onTapped) {
            VStack(alignment: .leading, spacing: 8) {
                imageSection
                contentSection
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private extension CommunityItemView {
    var imageSection: some View {
        AsyncImage(url: URL(string: item.filtered ?? "")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .fill(.gray15)
                .overlay {
                    ProgressView()
                        .tint(.gray30)
                }
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    var contentSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title ?? "Untitled Filter")
                .font(.pretendardFont(.body_bold, size: 14))
                .foregroundStyle(.gray75)
                .lineLimit(1)
            
            metaInfoSection
        }
    }
    
    var metaInfoSection: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(.gray30)
                .frame(width: 16, height: 16)
            
            Text("Community Filter")
                .font(.pretendardFont(.body_medium, size: 12))
                .foregroundStyle(.gray45)
                .lineLimit(1)
            
            if let likeCount = item.likeCount {
                Spacer()
                HStack(spacing: 2) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.gray45)
                    Text("\(likeCount)")
                        .font(.pretendardFont(.body_medium, size: 10))
                        .foregroundStyle(.gray45)
                }
            }
        }
    }
}
