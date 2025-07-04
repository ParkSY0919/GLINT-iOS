//
//  CategorySectionView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

struct CategorySectionView: View {
    let selectedCategory: FilterCategoryItem.CategoryType?
    let onCategorySelected: (FilterCategoryItem.CategoryType) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            titleSection
            categorySection
        }
        .padding(.top, 26)
    }
    
    private var titleSection: some View {
        Text(Strings.Make.category)
            .font(.pretendardFont(.body_bold, size: 16))
            .foregroundColor(.gray60)
    }
    
    private var categorySection: some View {
        HStack(spacing: 8) {
            ForEach(FilterCategoryItem.CategoryType.allCases, id: \.self) { category in
                categoryButton(
                    title: category.displayName,
                    isSelected: selectedCategory == category
                ) {
                    onCategorySelected(category)
                }
            }
            
            Spacer()
        }
    }
    
    private func categoryButton(
        title: String,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            Text(title)
                .font(.pretendardFont(.caption_semi, size: 14))
                .foregroundColor(isSelected ? .gray0 : .gray60)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? .brandDeep : .gray90)
                )
        }
        .buttonStyle(.plain)
    }
}
