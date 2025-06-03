//
//  TabBarView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

struct TabBarView: View {
    @State private var viewModel: TabBarViewModel
    @State private var tabBarVisibility = TabBarVisibilityManager()
    
    // 의존성 주입을 위한 초기화 추가
    init(todayPickUseCase: TodayPickUseCase) {
        self._viewModel = State(wrappedValue: TabBarViewModel(todayPickUseCase: todayPickUseCase))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch viewModel.selectedTab {
                case 0:
                    MainTab(
                        router: viewModel.mainRouter,
                        mainViewStore: viewModel.mainViewStore
                    )
                case 1:
                    FeedTab(router: viewModel.categoryRouter)
                case 2:
                    MakeTab(router: viewModel.recommendationsRouter)
                case 3:
                    SearchTabView(router: viewModel.searchRouter)
                case 4:
                    ProfileTabView(router: viewModel.profileRouter)
                default:
                    Text("알 수 없는 탭")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environment(tabBarVisibility)
            
            // 커스텀 탭 바
            CustomTabBar(
                selectedTab: Binding(
                    get: { viewModel.selectedTab },
                    set: { newValue in
                        // 탭 변경 시 탭바 표시
                        tabBarVisibility.showTabBar()
                        
                        if viewModel.selectedTab == newValue {
                            viewModel.resetTabToRoot(newValue)
                        } else {
                            viewModel.selectTab(newValue)
                        }
                    }
                ),
                items: TabBarItems.items
            )
            .opacity(tabBarVisibility.isVisible ? 1 : 0)
            .offset(y: tabBarVisibility.isVisible ? 0 : 100)
            .animation(.easeInOut(duration: 0.3), value: tabBarVisibility.isVisible)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

extension TabBarView {
    @ViewBuilder
    static func create() -> some View {
        EnvironmentReader { environment in
            TabBarView(todayPickUseCase: environment.todayPickUseCase)
        }
    }
}

struct MainTab: View {
    @Bindable var router: NavigationRouter<MainTabRoute>
    let mainViewStore: MainViewStore
    
    var body: some View {
        RouterNavigationStack(router: router) {
            MainView(
                router: router,
                store: mainViewStore  // Store 직접 전달!
            )
            .onAppear {
                // MainViewStore에 router 참조 설정
                mainViewStore.router = router
            }
        } destination: { route in
            destinationView(for: route)
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: MainTabRoute) -> some View {
        switch route {
        case .home:
            MainView(router: router, store: mainViewStore)
        case .detail(let id):
            DetailView(id: id, router: router)
        case .settings:
            SettingsView(router: router)
        }
    }
}

struct FeedTab: View {
    @Bindable var router: NavigationRouter<FeedTabRoute>
    
    var body: some View {
        RouterNavigationStack(router: router) {
            CategoryContentView(router: router)
        } destination: { route in
            destinationView(for: route)
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: FeedTabRoute) -> some View {
        switch route {
        case .categoryList:
            CategoryContentView(router: router)
        case .categoryDetail(let categoryId):
            CategoryDetailView(categoryId: categoryId, router: router)
        case .subCategory(let id):
            SubCategoryView(id: id, router: router)
        }
    }
}

struct MakeTab: View {
    @Bindable var router: NavigationRouter<MakeTabRoute>
    
    var body: some View {
        RouterNavigationStack(router: router) {
            MakeView()
        } destination: { route in
            destinationView(for: route)
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: MakeTabRoute) -> some View {
        switch route {
        case .make:
            MakeView()
        case .filterEditor:
            RecommendationDetailView(router: router)
        }
    }
}

struct SearchTabView: View {
    @Bindable var router: NavigationRouter<SearchTabRoute>
    
    var body: some View {
        RouterNavigationStack(router: router) {
            SearchContentView(router: router)
        } destination: { route in
            destinationView(for: route)
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: SearchTabRoute) -> some View {
        switch route {
        case .searchHome:
            SearchContentView(router: router)
        case .searchResults(let query):
            SearchResultsView(query: query, router: router)
        case .searchDetail(let id):
            SearchDetailView(id: id, router: router)
        }
    }
}

struct ProfileTabView: View {
    @Bindable var router: NavigationRouter<ProfileTabRoute>
    
    var body: some View {
        RouterNavigationStack(router: router) {
            ProfileContentView(router: router)
        } destination: { route in
            destinationView(for: route)
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: ProfileTabRoute) -> some View {
        switch route {
        case .profile:
            ProfileContentView(router: router)
        case .editProfile:
            EditProfileView(router: router)
        case .settings:
            ProfileSettingsView(router: router)
        case .orderHistory:
            OrderHistoryView(router: router)
        }
    }
}
