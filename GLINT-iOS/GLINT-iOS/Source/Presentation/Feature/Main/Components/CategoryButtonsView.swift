//
//  CategoryButtonsView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/21/25.
//

import SwiftUI

struct CategoryButtonsView: View {
    let categories: [FilterCategory]
    @State private var selectedCategory: FilterCategory?
    
    // 버튼 크기 및 내부 요소 스타일 상수 정의
    private let buttonSize: CGFloat = 56
    private let iconSize: CGFloat = 32
    private let textFontSize: CGFloat = 12
    private let spacingBetweenIconAndText: CGFloat = 2
    
    var body: some View {
        categoryButtonsContainer()
    }
    
    // MARK: - Container View
    private func categoryButtonsContainer() -> some View {
        HStack(spacing: 0) {
            ForEach(categories) { category in
                categoryButton(for: category)
                
                if categories.last != category {
                    Spacer()
                }
            }
        }
        .frame(height: buttonSize)
    }
    
    // MARK: - Category Button
    private func categoryButton(for category: FilterCategory) -> some View {
        Button {
            handleCategorySelection(category)
        } label: {
            categoryButtonContent(for: category)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Button Content
    private func categoryButtonContent(for category: FilterCategory) -> some View {
        categoryContentStack(for: category)
            .padding(.horizontal, 12)
            .frame(height: buttonSize)
            .background {
                categoryBackgroundShape()
            }
    }
    
    // MARK: - Background Shape
    private func categoryBackgroundShape() -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray75.opacity(0.4))
    }
    
    // MARK: - Content Stack
    private func categoryContentStack(for category: FilterCategory) -> some View {
        VStack(spacing: spacingBetweenIconAndText) {
            categoryIcon(for: category)
            categoryLabel(for: category)
        }
    }
    
    // MARK: - Icon
    private func categoryIcon(for category: FilterCategory) -> some View {
        category.icon
            .resizable()
            .scaledToFit()
            .frame(width: iconSize, height: iconSize)
            .foregroundColor(.gray60)
    }
    
    // MARK: - Label
    private func categoryLabel(for category: FilterCategory) -> some View {
        Text(category.name)
            .font(.pretendardFont(.caption_semi, size: 10))
            .foregroundColor(.gray60)
    }
    
    // MARK: - Actions
    private func handleCategorySelection(_ category: FilterCategory) {
        print("\(category.name) 카테고리 버튼 탭됨")
        self.selectedCategory = category
    }
}

#Preview {
    CategoryButtonsView(categories: DummyFilterAppData.categories)
//        .background(Color.black.opacity(0.1))  //배경색 추가하여 반투명 효과 확인
}

