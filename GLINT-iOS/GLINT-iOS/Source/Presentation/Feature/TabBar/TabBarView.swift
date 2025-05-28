import SwiftUI

struct TabBarView: View {
    var viewModel = TabBarViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch viewModel.selectedTab {
                case 0: 
                    MainTabView(router: viewModel.mainRouter)
                case 1: 
                    CategoryTabView(router: viewModel.categoryRouter)
                case 2: 
                    RecommendationsTabView(router: viewModel.recommendationsRouter)
                case 3: 
                    SearchTabView(router: viewModel.searchRouter)
                case 4: 
                    ProfileTabView(router: viewModel.profileRouter)
                default:
                    Text("알 수 없는 탭")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 커스텀 탭 바
            CustomTabBar(
                selectedTab: Binding(
                    get: { viewModel.selectedTab },
                    set: { newValue in
                        // 같은 탭을 다시 누르면 루트로 이동
                        if viewModel.selectedTab == newValue {
                            viewModel.resetTabToRoot(newValue)
                        } else {
                            viewModel.selectTab(newValue)
                        }
                    }
                ),
                items: TabBarItems.items
            )
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// MARK: - Tab Content Views
struct MainTabView: View {
    @Bindable var router: NavigationRouter<MainTabRoute>
    
    var body: some View {
        RouterNavigationStack(router: router) {
            MainView(router: router)
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
        case .settings:
            SettingsView(router: router)
        }
    }
}

struct CategoryTabView: View {
    @Bindable var router: NavigationRouter<CategoryTabRoute>
    
    var body: some View {
        RouterNavigationStack(router: router) {
            CategoryContentView(router: router)
        } destination: { route in
            destinationView(for: route)
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: CategoryTabRoute) -> some View {
        switch route {
        case .categoryList:
            CategoryContentView(router: router)
        case .categoryDetail(let categoryId):
            CategoryDetailView(categoryId: categoryId, router: router)
        case .subCategory(let id):
            SubCategoryView(id: id, router: router)
        }
    }
}

struct RecommendationsTabView: View {
    @Bindable var router: NavigationRouter<RecommendationsTabRoute>
    
    var body: some View {
        RouterNavigationStack(router: router) {
            RecommendationsContentView(router: router)
        } destination: { route in
            destinationView(for: route)
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: RecommendationsTabRoute) -> some View {
        switch route {
        case .recommendationsList:
            RecommendationsContentView(router: router)
        case .recommendationDetail(let id):
            RecommendationDetailView(id: id, router: router)
        case .favorites:
            FavoritesView(router: router)
        }
    }
}

struct SearchTabView: View {
    @Bindable var router: NavigationRouter<SearchTabRoute>
    
    var body: some View {
        RouterNavigationStack(router: router) {
            SearchContentView(router: router)
        } destination: { route in
            destinationView(for: route)
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: SearchTabRoute) -> some View {
        switch route {
        case .searchHome:
            SearchContentView(router: router)
        case .searchResults(let query):
            SearchResultsView(query: query, router: router)
        case .searchDetail(let id):
            SearchDetailView(id: id, router: router)
        }
    }
}

struct ProfileTabView: View {
    @Bindable var router: NavigationRouter<ProfileTabRoute>
    
    var body: some View {
        RouterNavigationStack(router: router) {
            ProfileContentView(router: router)
        } destination: { route in
            destinationView(for: route)
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: ProfileTabRoute) -> some View {
        switch route {
        case .profile:
            ProfileContentView(router: router)
        case .editProfile:
            EditProfileView(router: router)
        case .settings:
            ProfileSettingsView(router: router)
        case .orderHistory:
            OrderHistoryView(router: router)
        }
    }
}

#Preview {
    TabBarView()
} 
