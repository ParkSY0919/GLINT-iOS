//
//  MainTab.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/26/25.
//

import SwiftUI

struct MainTab: View {
    @Environment(NavigationRouter<MainTabRoute>.self)
    private var router
    @Environment(\.detailViewUseCase)
    private var detailViewUseCase
    
    
    var body: some View {
        RouterNavigationStack(router: router) {
            MainView()
        } destination: { route in
            destinationView(for: route)
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: MainTabRoute) -> some View {
        switch route {
        case .home:
            MainView()
        case .detail(let id):
            DetailView(id: id)
                .environment(DetailViewStore(useCase: detailViewUseCase, router: router))
        case .chat(let otherUserId, let otherUserName):
            let chatStore = ChatViewStore(router: router, otherUserId: otherUserId, otherUserName: otherUserName)
            ChatView(otherUserId: otherUserId, otherUserName: otherUserName, store: chatStore)
        }
    }
}
