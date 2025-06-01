//
//  ContentView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/9/25.
//

import SwiftUI

struct ContentView: View {
    @State private var rootRouter = RootRouter()
    
    var body: some View {
        Group {
            switch rootRouter.currentRoute {
            case .login:
                LoginView(rootRouter: rootRouter)
            case .tabBar:
                TabBarView.create()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: rootRouter.currentRoute)
    }
}

#Preview {
    ContentView()
}
