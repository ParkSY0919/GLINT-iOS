//
//  CommunityTab.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/26/25.
//

import SwiftUI

struct CommunityTab: View {
    @Environment(NavigationRouter<CommunityTabRoute>.self)
    private var router
    
    var body: some View {
        RouterNavigationStack(router: router) {
            CommunityView()
        } destination: { route in
            destinationView(for: route)
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: CommunityTabRoute) -> some View {
        switch route {
        case .community:
            CommunityView()
        case .communityDetail(let id):
            CommunityDetailView(id: id)
        }
    }
}
