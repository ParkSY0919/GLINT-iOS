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
final class RootRouter {
    enum Route: Hashable {
        case signIn
        case tabBar
    }
    
    var currentRoute: Route = .signIn
    
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
    
    // 데이터 전달용 저장소 - 타겟 경로 길이를 키로 사용
    private var popCallbacks: [Int: (Any) -> Void] = [:]
    
    private var popCallbacksOverData: [Int: (Any, Any) -> Void] = [:]
    
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
    
    // 데이터와 함께 이전 화면으로 돌아가기
    func pop<T, U>(withData data: T, addData: U) {
        let targetRouteIndex = path.count - 1
        print("🔄 Attempting to pop with data. Target route index: \(targetRouteIndex)")
        print("🔄 Available callbacks: \(Array(popCallbacksOverData.keys))")
        
        // 저장된 콜백이 있으면 실행
        if let callback = popCallbacksOverData[targetRouteIndex] {
            print("✅ Found callback for target route index: \(targetRouteIndex)")
            callback(data, addData)
            popCallbacksOverData.removeValue(forKey: targetRouteIndex)
        } else {
            print("❌ No callback found for target route index: \(targetRouteIndex)")
        }
        pop()
    }

    // 데이터 수신 콜백 등록
    func onPopData<T, U>(_ tType: T.Type, _ uType: U.Type, callback: @escaping (T, U) -> Void) {
        let currentRouteIndex = path.count
        print("📝 Registering callback for route index: \(currentRouteIndex), types: \(tType), \(uType)")
        
        popCallbacksOverData[currentRouteIndex] = { tData, uData in
            print("🎯 Callback executed for route index: \(currentRouteIndex)")
            if let tTypedData = tData as? T,
               let uTypedData = uData as? U {
                print("✅ Data types match: \(tType), \(uType)")
                callback(tTypedData, uTypedData)
            } else {
                print("❌ Data type mismatch. Expected: (\(tType), \(uType)), Got: (\(type(of: tData)), \(type(of: uData)))")
            }
        }
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
    case chat(otherUserId: String, otherUserName: String)
}

enum MakeTabRoute: Hashable {
    case make
    case edit(originImage: UIImage)
}
