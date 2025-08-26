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
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(items) { item in
                CommunityItemView(
                    item: item,
                    onTapped: {
                        onItemTapped(item.id)
                    }
                )
            }
        }
        .padding(.horizontal, 20)
    }
}