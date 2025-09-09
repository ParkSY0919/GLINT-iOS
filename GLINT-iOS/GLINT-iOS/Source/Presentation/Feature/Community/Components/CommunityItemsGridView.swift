//
//  CommunityItemsGridView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/26/25.
//

import SwiftUI

struct CommunityItemsGridView: View {
    let items: [FilterEntity]
    let onItemTapped: (String) -> Void
    
    // CommunityItemView에서 정의한 고정 크기 사용
    private let columns = Array(repeating: GridItem(.fixed(CommunityItemView.cellWidth), spacing: 20), count: 2)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(items) { item in
                CommunityItemView(
                    item: item,
                    onTapped: {
                        onItemTapped(item.id)
                    }
                )
                // CommunityItemView 내부에서 이미 고정 크기가 설정되어 있으므로 추가 frame 설정 불필요
            }
        }
        .padding(.horizontal, 20)
    }
}