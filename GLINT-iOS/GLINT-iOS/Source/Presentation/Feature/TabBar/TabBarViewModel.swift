//
//  TabBarViewModel.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

@MainActor
@Observable
final class TabBarViewModel {
    var selectedTab: Int = 0
    
    // 각 탭 NavigationRouter
    let mainRouter = NavigationRouter<MainTabRoute>()
    let makeRouter = NavigationRouter<MakeTabRoute>()
    
    // 각 탭의 Store 관리
    let mainViewStore: MainViewStore
    let makeViewStore: MakeViewStore
    
    /// 의존성 주입을 통한 초기화
    init(
        mainViewUseCase: MainViewUseCase,
        makeViewUseCase: MakeViewUseCase
    ) {
        self.mainViewStore = MainViewStore(useCase: mainViewUseCase, router: mainRouter)
        self.makeViewStore = MakeViewStore(useCase: makeViewUseCase, router: makeRouter)
    }
    
    func selectTab(_ index: Int) {
        selectedTab = index
    }
    
    // 탭 변경 시 해당 탭의 루트로 이동
    func resetTabToRoot(_ index: Int) {
        switch index {
        case 0: mainRouter.popToRoot()
        case 2: makeRouter.popToRoot()
        default: break
        }
    }
}
