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
    init(mainViewUseCase: MainViewUseCase, makeViewUseCase: MakeViewUseCase) {
        self._viewModel = State(
            wrappedValue: TabBarViewModel(
                mainViewUseCase: mainViewUseCase,
                makeViewUseCase: makeViewUseCase
            )
        )
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
                case 2:
                    MakeTab(
                        router: viewModel.makeRouter,
                        makeViewStore: viewModel.makeViewStore
                    )
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
            TabBarView(
                mainViewUseCase: environment.mainViewUseCase,
                makeViewUseCase: environment.makeViewUseCase
            )
        }
    }
}

struct MainTab: View {
    @Bindable var router: NavigationRouter<MainTabRoute>
    let mainViewStore: MainViewStore
    
    var body: some View {
        RouterNavigationStack(router: router) {
            MainView(router: router, store: mainViewStore)
//                .onAppear {
//                    mainViewStore.router = router
//                }
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
        }
    }
}

struct MakeTab: View {
    @Bindable var router: NavigationRouter<MakeTabRoute>
    let makeViewStore: MakeViewStore
    
    var body: some View {
        RouterNavigationStack(router: router) {
            MakeView(store: makeViewStore)
        } destination: { route in
            destinationView(for: route)
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: MakeTabRoute) -> some View {
        switch route {
        case .make:
            MakeView(store: makeViewStore)
        }
    }
}
