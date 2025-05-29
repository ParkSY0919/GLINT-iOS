//
//  Router.swift
//  GLINT-iOS
//
//  Created by System on 2024/03/19.
//

import SwiftUI

// MARK: - Router Protocol
protocol Router {
    associatedtype V: View
    var currentView: V { get }
}

// MARK: - RootRouter
@Observable
final class RootRouter: Router {
    enum Route: Hashable {
        case login
        case tabBar
    }
    
    var currentRoute: Route = .login
    
    @ViewBuilder
    var currentView: some View {
        switch currentRoute {
        case .login:
            LoginView(rootRouter: self)
        case .tabBar:
            TabBarView()
        }
    }
    
    // 화면 전환 메서드
    func navigate(to route: Route) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentRoute = route
        }
    }
}

// MARK: - NavigationRouter
@Observable
final class NavigationRouter<Route: Hashable>: Router {
    // 현재 네비게이션 스택의 경로
    var path: [Route] = []
    
    // 현재 보여지는 뷰 (Router 프로토콜 준수용)
    var currentView: some View {
        EmptyView()
    }
    
    // MARK: - Navigation Methods
    
    // 새로운 화면으로 이동
    func push(_ route: Route) {
        path.append(route)
    }
    
    // 이전 화면으로 돌아가기
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    // 루트 화면으로 돌아가기
    func popToRoot() {
        path.removeAll()
    }
    
    // 특정 화면까지 pop
    func pop(to route: Route) {
        guard let index = path.firstIndex(of: route) else { return }
        path = Array(path.prefix(through: index))
    }
    
    // 여러 화면을 한 번에 push
    func push(routes: [Route]) {
        path.append(contentsOf: routes)
    }
    
    // 현재 경로 교체
    func replace(with routes: [Route]) {
        path = routes
    }
    
    // 현재 위치에서 특정 화면으로 교체
    func replace(current route: Route) {
        if !path.isEmpty {
            path[path.count - 1] = route
        } else {
            path.append(route)
        }
    }
}

// MARK: - RouterNavigationStack
struct RouterNavigationStack<Route: Hashable, RootContent: View, Destination: View>: View {
    @Bindable var router: NavigationRouter<Route>
    @ViewBuilder let rootContent: () -> RootContent
    @ViewBuilder let destination: (Route) -> Destination
    
    var body: some View {
        NavigationStack(path: $router.path) {
            rootContent()
                .navigationDestination(for: Route.self) { route in
                    destination(route)
                }
        }
    }
}

// MARK: - Tab Routes
enum MainTabRoute: Hashable {
    case home
    case detail(id: String)
    case settings
}

enum CategoryTabRoute: Hashable {
    case categoryList
    case categoryDetail(categoryId: String)
    case subCategory(id: String)
}

enum RecommendationsTabRoute: Hashable {
    case recommendationsList
    case recommendationDetail(id: String)
    case favorites
}

enum SearchTabRoute: Hashable {
    case searchHome
    case searchResults(query: String)
    case searchDetail(id: String)
}

enum ProfileTabRoute: Hashable {
    case profile
    case editProfile
    case settings
    case orderHistory
}

// MARK: - App Routes
enum AppRoute: Hashable {
    case home
    case profile(userId: String)
    case settings
    case detail(id: Int)
    case userList
}
