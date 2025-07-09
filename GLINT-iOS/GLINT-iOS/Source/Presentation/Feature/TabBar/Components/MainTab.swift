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
    
    // DetailViewStore 캐싱을 위한 딕셔너리
    @State private var detailViewStores: [String: DetailViewStore] = [:]
    
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
                .environment(getOrCreateDetailViewStore(for: id))
        case .chat(let otherUserId, let otherUserName):
            let chatStore = ChatViewStore(router: router, otherUserId: otherUserId, otherUserName: otherUserName)
            ChatView(otherUserId: otherUserId, otherUserName: otherUserName, store: chatStore)
        }
    }
    
    // DetailViewStore를 ID별로 캐싱하는 메서드
    private func getOrCreateDetailViewStore(for id: String) -> DetailViewStore {
        if let existingStore = detailViewStores[id] {
            return existingStore
        }
        
        let newStore = DetailViewStore(useCase: detailViewUseCase, router: router)
        detailViewStores[id] = newStore
        return newStore
    }
}
