import SwiftUI

// MARK: - Main Tab Detail Views
struct DetailView: View {
    let id: String
    let router: NavigationRouter<MainTabRoute>
    
    var body: some View {
        VStack {
            Text("상세 화면")
                .font(.title)
            Text("ID: \(id)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .navigationTitle("상세")
    }
}

struct SettingsView: View {
    let router: NavigationRouter<MainTabRoute>
    
    var body: some View {
        Text("설정")
            .navigationTitle("설정")
    }
}

// MARK: - Category Tab Detail Views
struct CategoryDetailView: View {
    let categoryId: String
    let router: NavigationRouter<FeedTabRoute>
    
    var body: some View {
        List {
            ForEach(1...5, id: \.self) { index in
                Button("하위 카테고리 \(index)") {
                    router.push(.subCategory(id: "\(categoryId)-sub-\(index)"))
                }
            }
        }
        .navigationTitle("카테고리 상세")
    }
}

struct SubCategoryView: View {
    let id: String
    let router: NavigationRouter<FeedTabRoute>
    
    var body: some View {
        Text("하위 카테고리: \(id)")
            .navigationTitle("하위 카테고리")
    }
}

// MARK: - Recommendations Tab Detail Views
struct RecommendationDetailView: View {
    let router: NavigationRouter<MakeTabRoute>
    
    var body: some View {
        Text("추천 상세: ")
            .navigationTitle("추천 상세")
    }
}

struct FavoritesView: View {
    let router: NavigationRouter<MakeTabRoute>
    
    var body: some View {
        Text("즐겨찾기")
            .navigationTitle("즐겨찾기")
    }
}

// MARK: - Search Tab Detail Views
struct SearchResultsView: View {
    let query: String
    let router: NavigationRouter<SearchTabRoute>
    
    var body: some View {
        Text("검색 결과: \(query)")
            .navigationTitle("검색 결과")
    }
}

struct SearchDetailView: View {
    let id: String
    let router: NavigationRouter<SearchTabRoute>
    
    var body: some View {
        Text("검색 상세: \(id)")
            .navigationTitle("검색 상세")
    }
}

// MARK: - Profile Tab Detail Views
struct EditProfileView: View {
    let router: NavigationRouter<ProfileTabRoute>
    
    var body: some View {
        Text("프로필 편집")
            .navigationTitle("프로필 편집")
    }
}

struct ProfileSettingsView: View {
    let router: NavigationRouter<ProfileTabRoute>
    
    var body: some View {
        Text("프로필 설정")
            .navigationTitle("설정")
    }
}

struct OrderHistoryView: View {
    let router: NavigationRouter<ProfileTabRoute>
    
    var body: some View {
        Text("주문 내역")
            .navigationTitle("주문 내역")
    }
} 
