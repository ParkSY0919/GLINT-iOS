//
//  MakeTab.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/26/25.
//

import SwiftUI

struct MakeTab: View {
    @Environment(NavigationRouter<MakeTabRoute>.self)
    private var router
    
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
