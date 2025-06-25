//
//  TabBarView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

struct TabBarView: View {
    @Environment(\.mainViewUseCase)
    private var mainViewUseCase
    
    @Environment(\.makeViewUseCase)
    private var makeViewUseCase
    
    @State private var viewModel: TabBarViewModel?
    @State private var tabBarVisibility = TabBarVisibilityManager()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let viewModel = viewModel {
                Group {
                    switch viewModel.selectedTab {
                    case 0:
                        MainTab(
                            router: viewModel.mainRouter
                        )
                        .environment(viewModel.mainViewStore)
                    case 2:
                        MakeTab(
                            router: viewModel.makeRouter
                        )
                        .environment(viewModel.makeViewStore)
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
            } else {
                // 로딩 상태
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = TabBarViewModel(
                    mainViewUseCase: mainViewUseCase,
                    makeViewUseCase: makeViewUseCase
                )
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// MARK: - Factory Method (기존 create 메서드는 제거하거나 단순화)
extension TabBarView {
    @ViewBuilder
    static func create() -> some View {
        TabBarView()
    }
}

// MARK: - Tab Views
struct MainTab: View {
    @Bindable var router: NavigationRouter<MainTabRoute>
    @Environment(MainViewStore.self) private var store
    
    var body: some View {
        RouterNavigationStack(router: router) {
            MainView(router: router)
                .onAppear {
                    store.router = router
                }
        } destination: { route in
            destinationView(for: route)
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: MainTabRoute) -> some View {
        switch route {
        case .home:
            MainView(router: router)
        case .detail(let id):
            DetailView(id: id, router: router)
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
        }
    }
}
