import SwiftUI

@Observable
final class TabBarViewModel {
    var selectedTab: Int = 0
    
    // 각 탭별 NavigationRouter
    var mainRouter = NavigationRouter<MainTabRoute>()
    var categoryRouter = NavigationRouter<CategoryTabRoute>()
    var recommendationsRouter = NavigationRouter<RecommendationsTabRoute>()
    var searchRouter = NavigationRouter<SearchTabRoute>()
    var profileRouter = NavigationRouter<ProfileTabRoute>()
    
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
