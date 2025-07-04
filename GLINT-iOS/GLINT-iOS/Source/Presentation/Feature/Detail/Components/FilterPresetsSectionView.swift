//
//  FilterPresetsSectionView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

struct FilterPresetsSectionView: View {
    let isPurchased: Bool
    let filterPresetsData: [String]?
    
    var body: some View {
        contentView
            .padding(.horizontal, 20)
            .padding(.top, 24)
    }
}

private extension FilterPresetsSectionView {
    var contentView: some View {
        VStack(spacing: 0) {
            containerView
        }
    }
    
    var containerView: some View {
        VStack(spacing: 0) {
            titleBarSection
            presetsContentSection
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(.brandBlack, lineWidth: 1)
        )
    }
    
    var titleBarSection: some View {
        HStack {
            Text(Strings.Detail.filterPresets)
                .font(.pretendardFont(.caption_semi, size: 12))
                .foregroundColor(.brandDeep)
            
            Spacer()
            
            Text(Strings.Detail.lutLabel)
                .font(.pretendardFont(.caption_semi, size: 12))
                .foregroundColor(.brandDeep)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.gray100)
        .clipShape(
            .rect(
                topLeadingRadius: 12,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 12
            )
        )
    }
    
    var presetsContentSection: some View {
        ZStack {
            backgroundSection
            
            if isPurchased {
                unlockedPresetsSection
            } else {
                lockedPresetsSection
            }
        }
        .frame(height: 140)
    }
    
    var backgroundSection: some View {
        Rectangle()
            .fill(.brandBlack)
            .clipShape(
                .rect(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 12,
                    bottomTrailingRadius: 12,
                    topTrailingRadius: 0
                )
            )
    }
    
    var unlockedPresetsSection: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 6),
            spacing: 16
        ) {
            ForEach(0..<12, id: \.self) { index in
                presetItem(at: index)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    var lockedPresetsSection: some View {
        ZStack {
            unlockedPresetsSection
                .blur(radius: 3)
            
            lockOverlaySection
        }
    }
    
    var lockOverlaySection: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.system(size: 32))
                .foregroundColor(.gray0)
            
            Text(Strings.Detail.Purchase.lockedFilterMessage)
                .font(.pretendardFont(.body_bold, size: 16))
                .foregroundColor(.gray45)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
    
    func presetItem(at index: Int) -> some View {
        VStack(spacing: 4) {
            let icons = Images.Detail.filterValues
            if let data = filterPresetsData {
                icons[index]
                    .font(.system(size: 20))
                    .foregroundColor(.gray0)
                    .frame(width: 28, height: 28)
                
                Text(data[index])
                    .font(.pretendardFont(.body_bold, size: 14))
                    .foregroundColor(.gray75)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
