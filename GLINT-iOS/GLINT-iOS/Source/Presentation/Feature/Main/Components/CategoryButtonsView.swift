//
//  CategoryButtonsView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/21/25.
//

import SwiftUI

// MARK: - 카테고리 모델
struct FilterCategoryModel: Identifiable, Equatable {
    let id = UUID()
    let icon: Image
    let name: String
}

struct CategoryButtonsView: View {
    private let categories: [FilterCategoryModel] = StringLiterals.categories
    let onTapCategory: (FilterCategoryModel) -> Void
    
    // 버튼 크기 및 내부 요소 스타일 상수 정의
    private let buttonSize: CGFloat = 56
    private let iconSize: CGFloat = 32
    private let textFontSize: CGFloat = 12
    private let spacingBetweenIconAndText: CGFloat = 2
    
    var body: some View {
        contentView
            .frame(height: buttonSize)
    }
}

private extension CategoryButtonsView {
    var contentView: some View {
        HStack(spacing: 0) {
            ForEach(categories) { category in
                categoryButton(for: category)
                if categories.last != category {
                    Spacer()
                }
            }
        }
    }
    
    func categoryButton(for category: FilterCategoryModel) -> some View {
        Button {
            handleCategorySelection(category)
        } label: {
            categoryButtonContent(for: category)
        }
        .buttonStyle(.plain)
    }
    
    func categoryButtonContent(for category: FilterCategoryModel) -> some View {
        categoryContentStack(for: category)
            .padding(.horizontal, 12)
            .frame(height: buttonSize)
            .background {
                categoryBackgroundShape
            }
    }
    
    var categoryBackgroundShape: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray75.opacity(0.4))
    }
    
    func categoryContentStack(for category: FilterCategoryModel) -> some View {
        VStack(spacing: spacingBetweenIconAndText) {
            categoryIcon(for: category)
            categoryLabel(for: category)
        }
    }
    
    func categoryIcon(for category: FilterCategoryModel) -> some View {
        category.icon
            .resizable()
            .scaledToFit()
            .frame(width: iconSize, height: iconSize)
            .foregroundColor(.gray60)
    }
    
    func categoryLabel(for category: FilterCategoryModel) -> some View {
        Text(category.name)
            .font(.pretendardFont(.caption_semi, size: 10))
            .foregroundColor(.gray60)
    }
    
    func handleCategorySelection(_ category: FilterCategoryModel) {
        print("\(category.name) 카테고리 버튼 탭됨")
        self.onTapCategory(category)
    }
}
