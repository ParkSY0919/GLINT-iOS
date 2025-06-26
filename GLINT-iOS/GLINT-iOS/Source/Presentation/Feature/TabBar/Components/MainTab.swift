//
//  MainTab.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/26/25.
//

import SwiftUI

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
