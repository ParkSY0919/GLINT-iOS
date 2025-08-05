//
//  RootView.swift
//  GLINT-iOS
//
//  Created by 박신영
//

import SwiftUI

struct RootView: View {
    @State private var rootRouter = RootRouter()
    @Environment(\.loginViewUseCase) private var loginViewUseCase
    
    var body: some View {
        Group {
            switch rootRouter.currentRoute {
            case .signIn:
                LoginView()
                    .environment(LoginViewStore(useCase: loginViewUseCase, rootRouter: rootRouter))
            case .tabBar:
                TabBarView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: rootRouter.currentRoute)
        .onReceive(NotificationCenter.default.publisher(for: .authTokenExpired)) { _ in
            GTLogger.shared.d("logout")
            rootRouter.navigate(to: .signIn)
        }
    }
}

#Preview {
    RootView()
}
