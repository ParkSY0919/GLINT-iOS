//
//  CategorySectionView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

struct CategorySectionView: View {
    @Binding var selectedCategory: CategoryType?
    let onCategorySelected: (CategoryType) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("카테고리")
                .font(.pretendardFont(.body_bold, size: 16))
                .foregroundColor(.gray60)
            
            HStack(spacing: 8) {
                ForEach(CategoryType.allCases, id: \.self) { category in
                    CategoryButton(
                        title: category.displayName,
                        isSelected: selectedCategory == category
                    ) {
                        onCategorySelected(category)
                    }
                }
                
                Spacer()
            }
        }
        .padding(.top, 26)
    }
}

private struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
