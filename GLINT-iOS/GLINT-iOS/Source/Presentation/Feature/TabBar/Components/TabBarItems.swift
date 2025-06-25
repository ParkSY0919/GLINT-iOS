//
//  TabBarItems.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

struct TabBarItemModel: Identifiable {
    let id = UUID()
    let icon: Image // 비선택 시 아이콘
    let selectedIcon: Image // 선택 시 아이콘
    let title: String // 탭 이름
    let tag: Int // 탭 식별자
}

struct TabBarItems {   
    static let items: [TabBarItemModel] = [
        TabBarItemModel(
            icon: ImageLiterals.TabBar.home,
            selectedIcon: ImageLiterals.TabBar.homeSelected,
            title: "HOME",
            tag: 0
        ),
        TabBarItemModel(
            icon: ImageLiterals.TabBar.grid,
            selectedIcon: ImageLiterals.TabBar.gridSelected,
            title: "FEED",
            tag: 1
        ),
        TabBarItemModel(
            icon: ImageLiterals.TabBar.sparkles,
            selectedIcon: ImageLiterals.TabBar.sparklesSelected,
            title: "MAKE",
            tag: 2
        ),
        TabBarItemModel(
            icon: ImageLiterals.TabBar.search,
            selectedIcon: ImageLiterals.TabBar.searchSelected,
            title: "SEARCH",
            tag: 3
        ),
        TabBarItemModel(
            icon: ImageLiterals.TabBar.profile,
            selectedIcon: ImageLiterals.TabBar.profileSelected,
            title: "PROFILE",
            tag: 4
        )
    ]
}
