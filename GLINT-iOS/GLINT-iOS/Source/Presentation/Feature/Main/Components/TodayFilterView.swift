//
//  TodayFilterView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/21/25.
//

import SwiftUI

import NukeUI

struct TodayFilterView: View {
    let filterEntity: FilterEntity?
    let onTryFilterTapped: (String) -> Void
    let onTapCategory: (FilterCategoryItem) -> Void
    private let backgroundGradient = Gradient(colors: [
        .clear,
        .black.opacity(0.2),
        .black.opacity(0.3),
        .black.opacity(0.4),
        .black.opacity(0.5),
        .black.opacity(0.7),
        .black.opacity(0.8),
        .black.opacity(0.9),
        .black.opacity(1.0)
    ])
    
    var body: some View {
        ZStack(alignment: .top) {
            if let filterEntity {
                backgroundSection(filterEntity.filtered ?? "")
                contentStackSection(filterEntity)
                tryButtonSection(filterEntity.id)
            } else {
                StateViewBuilder.emptyStateView(message: Strings.Main.Error.todayFilterLoadFailed)
            }
        }
        .frame(height: 555)
    }
}

private extension TodayFilterView {
    func backgroundSection(_ filterURL: String) -> some View {
        GTLazyImageView(urlString: filterURL) { image in
            GeometryReader { proxy in
                let global = proxy.frame(in: .global)
                let width = global.width
                image
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: 555)
                    .clipped()
                    .overlay {
                        LinearGradient(
                            gradient: backgroundGradient,
                            startPoint: .center,
                            endPoint: .bottom
                        )
                    }
            }
        }
    }
    
    func contentStackSection(_ entity: FilterEntity) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            smallTitleSection
            largeTitleSection(entity.title ?? "")
            descriptionSection(entity.description ?? "")
            categorySection
        }
        .padding(.horizontal, 20)
    }
    
    var smallTitleSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.pinterestRed)
            
            Text(Strings.Main.todayFilterIntro)
                .font(.pretendardFont(.body_medium, size: 13))
                .foregroundColor(.pinterestTextSecondary)
        }
    }
    
    func largeTitleSection(_ title: String) -> some View {
        Text(title)
            .font(.pointFont(.title, size: 32))
            .foregroundColor(.pinterestTextPrimary)
            .lineLimit(2, reservesSpace: true)
            .padding(.top, 4)
            .padding(.bottom, 20)
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
    }
    
    func descriptionSection(_ description: String) -> some View {
        Text(description)
            .font(.pretendardFont(.caption, size: 12))
            .foregroundColor(.pinterestTextSecondary)
            .lineLimit(4, reservesSpace: true)
    }
    
    var categorySection: some View {
        CategoryButtonsView(onTapCategory: { category in
            self.onTapCategory(category)
        })
        .padding(.top, 30)
        .frame(maxWidth: .infinity)
    }
    
    func tryButtonSection(_ filterID: String) -> some View {
        HStack {
            Spacer()
            Button {
                onTryFilterTapped(filterID)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "camera.filters")
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text(Strings.Main.tryFilter)
                        .font(.pretendardFont(.caption_medium, size: 14))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    ZStack {
                        LinearGradient(
                            colors: [.gradientStart, .gradientMid],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        
                        LinearGradient(
                            colors: [.glassLight, .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .pinterestRed.opacity(0.3), radius: 8, x: 0, y: 4)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 60)
        .padding(.trailing, 20)
    }
}
