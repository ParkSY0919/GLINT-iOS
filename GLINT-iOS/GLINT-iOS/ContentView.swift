//
//  ContentView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/9/25.
//

import SwiftUI

struct ContentView: View {
    @State private var rootRouter = RootRouter()  // ✅ 상태 유지
    
    var body: some View {
        rootView
            .animation(.easeInOut(duration: 0.3), value: rootRouter.currentRoute)
    }
}

extension ContentView {
    @ViewBuilder
    var rootView: some View {
        switch rootRouter.currentRoute {
        case .login:
            LoginView(rootRouter: rootRouter)
        case .tabBar:
            TabBarView()
        }
    }
}

#Preview {
    ContentView()
}
