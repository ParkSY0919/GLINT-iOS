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
            icon: Images.TabBar.home,
            selectedIcon: Images.TabBar.homeSelected,
            title: "HOME",
            tag: 0
        ),
        TabBarItemModel(
            icon: Images.TabBar.grid,
            selectedIcon: Images.TabBar.gridSelected,
            title: "FEED",
            tag: 1
        ),
        TabBarItemModel(
            icon: Images.TabBar.sparkles,
            selectedIcon: Images.TabBar.sparklesSelected,
            title: "MAKE",
            tag: 2
        ),
        TabBarItemModel(
            icon: Images.TabBar.search,
            selectedIcon: Images.TabBar.searchSelected,
            title: "SEARCH",
            tag: 3
        ),
        TabBarItemModel(
            icon: Images.TabBar.profile,
            selectedIcon: Images.TabBar.profileSelected,
            title: "PROFILE",
            tag: 4
        )
    ]
}
