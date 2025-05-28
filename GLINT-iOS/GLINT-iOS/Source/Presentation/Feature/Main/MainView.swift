//
//  MainView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/22/25.
//

import SwiftUI

struct MainView: View {
    let router: NavigationRouter<MainTabRoute>
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                TodayFilterView(
                    filter: DummyFilterAppData.todayFilter,
                    router: router
                )
                
                BannerView(
                    items: DummyFilterAppData.bannerItems,
                    router: router
                )
                .padding(.top, -15)
                
                HotTrendView(
                    trends: DummyFilterAppData.hotTrends,
                    router: router
                )
                .padding(.top, 30)
                
                TodayArtistView(
                    artist: DummyFilterAppData.todayArtist,
                    router: router
                )
                .padding(.top, 30)
            }
            .padding(.bottom, 20)
        }
        .ignoresSafeArea(.all, edges: .top)
        .background(.gray100)
    }
}


#Preview {
    MainView(router: NavigationRouter<MainTabRoute>())
        .preferredColorScheme(.dark)
}
