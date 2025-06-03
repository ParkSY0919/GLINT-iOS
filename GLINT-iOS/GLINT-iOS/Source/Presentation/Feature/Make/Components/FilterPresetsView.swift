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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FilterPropertyType.allCases, id: \.self) { property in
                    FilterPresetButton(
                        property: property,
                        isSelected: selectedProperty == property,
                        onTap: {
                            onPropertySelected(property)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
//            .frame(height: 80)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(height: 80)
        .background(.gray100)
    }
}

private struct FilterPresetButton: View {
    let property: FilterPropertyType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
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
