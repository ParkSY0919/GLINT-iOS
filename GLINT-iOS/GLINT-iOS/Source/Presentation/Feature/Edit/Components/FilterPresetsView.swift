//
//  FilterPresetsView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

struct FilterPresetsView: View {
    let selectedProperty: FilterPropertyType
    let onPropertySelected: (FilterPropertyType) -> Void
    
    var body: some View {
        ScrollViewReader { proxy in
            contentView
                .frame(height: 80)
                .background(.gray100)
                .onChange(of: selectedProperty) { _, newProperty in
                    if let index = FilterPropertyType.allCases.firstIndex(of: newProperty), index >= 2 {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo(newProperty, anchor: .center)
                        }
                    }
                }
        }
    }
}

private extension FilterPresetsView {
    var contentView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            scrollViewContent
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
    
    var scrollViewContent: some View {
        HStack(spacing: 12) {
            ForEach(FilterPropertyType.allCases, id: \.self) { property in
                filterPresetButton(
                    property: property,
                    isSelected: selectedProperty == property,
                    onTap: {
                        onPropertySelected(property)
                    }
                )
                .id(property)
            }
        }
    }
    
    func filterPresetButton(
        property: FilterPropertyType,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                // 아이콘
                property.iconName
                    .foregroundColor(isSelected ? .gray0 : .gray75)
                    .frame(width: 28, height: 28)
                
                // 텍스트
                Text(property.displayName)
                    .font(.pretendardFont(.caption_semi, size: 9))
                    .foregroundColor(isSelected ? .gray0 : .gray75)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 62)
    }
}
