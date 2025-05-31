//
//  MainView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/22/25.
//

import SwiftUI

struct MainView: View {
    let router: NavigationRouter<MainTabRoute>
    
    @Environment(\.todayPickUseCase.todayAuthor)
    private var todayPickAuthor
    @Environment(\.todayPickUseCase.todayFilter)
    private var todayPickFilter
    
    @State
    private var todayFilter: TodayFilterResponseEntity?
    
    @State
    private var todayArtist: TodayArtistResponseEntity?
    //    @State
    //    private var hotTrends: [FilterModel] = []
    
    @State
    private var isLoading: Bool = true
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                TodayFilterView(
                    todayFilter: $todayFilter,
                    router: router
                )
                
                BannerView(
                    items: DummyFilterAppData.bannerItems,
                    router: router
                )
                .padding(.top, 20)
                
                HotTrendView(
                    trends: DummyFilterAppData.hotTrends,
                    router: router
                )
                .padding(.top, 30)
                
                TodayArtistView(
                    todayArtist: $todayArtist,
                    router: router
                )
                .padding(.top, 30)
            }
            .padding(.bottom, 20)
        }
        .detectScroll()
        .ignoresSafeArea(.all, edges: .top)
        .background(.gray100)
        .task(bodyTask)
    }
}

private extension MainView {
    @Sendable
    func bodyTask() async {
        guard isLoading else { return }
        defer { isLoading = false }
        do {
            async let todayAuthor = todayPickAuthor()
            async let todayFilter = todayPickFilter()
            
            
            self.todayFilter = try await todayFilter
            self.todayArtist = try await todayAuthor
        } catch {
            print(error)
        }
    }
}


#Preview {
    MainView(router: NavigationRouter<MainTabRoute>())
        .preferredColorScheme(.dark)
}
