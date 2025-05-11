//
//  TabBarView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

struct TapBarView: View {
    @State private var selectedTab: Int = 0 // 현재 선택된 탭

    var body: some View {
        ZStack(alignment: .bottom) { // 탭 바를 하단에 고정하기 위해 ZStack 사용
            Group {
                switch selectedTab {
                case 0: HomeContentView()
                case 1: CategoryContentView()
                case 2: RecommendationsContentView()
                case 3: SearchContentView() // 검색 탭
                case 4: ProfileContentView() // 마이 탭
                default:
                    Text("알 수 없는 탭")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // 컨텐츠 뷰가 전체 영역 차지
            // 커스텀 탭 바
            CustomTabBar(selectedTab: $selectedTab, items: TabBarItems.items)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom) // 키보드 올라올 때 탭 바 같이 안 올라가도록
    }
}

struct HomeContentView: View {
    var body: some View {
        NavigationView{
            Text("홈 화면").navigationTitle("홈")
        }
    }
}

struct CategoryContentView: View {
    var body: some View {
        NavigationView{
            Text("카테고리 화면").navigationTitle("카테고리")
        }
    }
}
struct RecommendationsContentView: View {
    var body: some View {
        NavigationView{
            Text("추천 화면").navigationTitle("추천")
        }
    }
}
struct SearchContentView: View {
    var body: some View {
        NavigationView{
            Text("검색 화면").navigationTitle("검색")
        }
    }
}
struct ProfileContentView: View {
    var body: some View {
        NavigationView{
            Text("마이 화면").navigationTitle("마이")
        }
    }
}

#Preview {
    TapBarView()
}
