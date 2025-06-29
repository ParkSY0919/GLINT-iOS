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
    
    @State
    private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            if let filterEntity {
                backgroundSection(filterEntity.filtered ?? "")
                contentStackSection(filterEntity)
                tryButtonSection(filterEntity.id)
            } else {
                StateViewBuilder.emptyStateView(message: "오늘의 필터를 불러올 수 없습니다")
            }
        }
        .frame(height: 555)
    }
}

private extension TodayFilterView {
    func backgroundSection(_ filterURL: String) -> some View {
        LazyImage(url: URL(string: filterURL)) { state in
            lazyImageTransform(state) { image in
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
        Text("오늘의 필터 소개")
            .font(.pretendardFont(.body_medium, size: 13))
            .foregroundStyle(.gray60)
            .foregroundColor(.white.opacity(0.8))
    }
    
    func largeTitleSection(_ title: String) -> some View {
        Text(title)
            .font(.pointFont(.title, size: 32))
            .foregroundColor(.gray30)
            .lineLimit(2, reservesSpace: true)
            .padding(.top, 4)
            .padding(.bottom, 20)
    }
    
    func descriptionSection(_ description: String) -> some View {
        Text(description)
            .font(.pretendardFont(.caption, size: 12))
            .foregroundStyle(.gray60)
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
                Text("사용해보기")
                    .font(.pretendardFont(.caption_medium, size: 12))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.gray75.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .foregroundColor(.gray0)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 60)
        .padding(.trailing, 20)
    }
}
