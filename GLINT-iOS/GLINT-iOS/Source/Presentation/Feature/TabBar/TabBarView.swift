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
    
    @State
    private var viewModel = TabBarViewModel(
           mainViewUseCase: MainViewUseCase.liveValue,
           makeViewUseCase: MakeViewUseCase.liveValue
           )
    @State private var tabBarVisibility = TabBarVisibilityManager()
    
    var body: some View {
        ZStack(alignment: .bottom) {
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
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
