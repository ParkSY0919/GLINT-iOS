//
//  TabBarViewModel.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

@Observable
final class TabBarViewModel {
    var selectedTab: Int = 0
    
    // 각 탭 NavigationRouter
    var mainRouter = NavigationRouter<MainTabRoute>()
    var categoryRouter = NavigationRouter<FeedTabRoute>()
    var recommendationsRouter = NavigationRouter<MakeTabRoute>()
    var searchRouter = NavigationRouter<SearchTabRoute>()
    var profileRouter = NavigationRouter<ProfileTabRoute>()
    
    // 각 탭의 Store 관리
    let mainViewStore: MainViewStore
    
    /// 의존성 주입을 통한 초기화
    init(mainViewUseCase: MainViewUseCase) {
        self.mainViewStore = MainViewStore(todayPickUseCase: mainViewUseCase)
    }
    
    func selectTab(_ index: Int) {
        selectedTab = index
    }
    
    // 탭 변경 시 해당 탭의 루트로 이동
    func resetTabToRoot(_ index: Int) {
        switch index {
        case 0: mainRouter.popToRoot()
        case 1: categoryRouter.popToRoot()
        case 2: recommendationsRouter.popToRoot()
        case 3: searchRouter.popToRoot()
        case 4: profileRouter.popToRoot()
        default: break
        }
    }
}
