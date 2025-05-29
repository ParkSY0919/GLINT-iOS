import SwiftUI

struct CategoryContentView: View {
    let router: NavigationRouter<CategoryTabRoute>
    
    var body: some View {
        List {
            ForEach(1...10, id: \.self) { index in
                Button("카테고리 \(index)") {
                    router.push(.categoryDetail(categoryId: "category-\(index)"))
                }
            }
        }
        .detectListScroll()
        .navigationTitle("카테고리")
    }
}

struct RecommendationsContentView: View {
    let router: NavigationRouter<RecommendationsTabRoute>
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(1...5, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text("추천 \(index)")
                            .font(.headline)
                        Text("추천 설명 \(index)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("자세히 보기") {
                            router.push(.recommendationDetail(id: "rec-\(index)"))
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
        .detectScroll()
        .navigationTitle("추천")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("즐겨찾기") {
                    router.push(.favorites)
                }
            }
        }
    }
}

struct SearchContentView: View {
    let router: NavigationRouter<SearchTabRoute>
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText) {
                if !searchText.isEmpty {
                    router.push(.searchResults(query: searchText))
                }
            }
            
            Spacer()
            
            Text("검색어를 입력하세요")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .nonScrollable()
        .padding()
        .navigationTitle("검색")
    }
}

struct ProfileContentView: View {
    let router: NavigationRouter<ProfileTabRoute>
    
    var body: some View {
        List {
            Section {
                HStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading) {
                        Text("사용자 이름")
                            .font(.headline)
                        Text("user@example.com")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("편집") {
                        router.push(.editProfile)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section {
                NavigationButton(title: "주문 내역", systemImage: "bag") {
                    router.push(.orderHistory)
                }
                
                NavigationButton(title: "설정", systemImage: "gear") {
                    router.push(.settings)
                }
            }
        }
        .detectListScroll()
        .navigationTitle("마이")
    }
}

// MARK: - Helper Views
struct SearchBar: View {
    @Binding var text: String
    let onSearchButtonClicked: () -> Void
    
    var body: some View {
        HStack {
            TextField("검색어 입력", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    onSearchButtonClicked()
                }
            
            Button("검색", action: onSearchButtonClicked)
                .buttonStyle(.borderedProminent)
        }
    }
}

struct NavigationButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .foregroundColor(.primary)
    }
} 
