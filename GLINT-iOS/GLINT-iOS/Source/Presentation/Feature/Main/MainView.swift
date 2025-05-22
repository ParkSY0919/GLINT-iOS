//
//  MainView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/22/25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    TodayFilterView(filter: DummyFilterAppData.todayFilter)
                    
                    BannerView(items: DummyFilterAppData.bannerItems)
                        .padding(.top, -15)
                    
                    HotTrendView(trends: DummyFilterAppData.hotTrends)
                        .padding(.top, 30)
                    
                    TodayArtistView(artist: DummyFilterAppData.todayArtist)
                        .padding(.top, 30)
                }
                .padding(.bottom, 20)
            }
            .ignoresSafeArea(.all, edges: .top)
        }
    }
}

#Preview {
    MainView()
        .preferredColorScheme(.dark)
}

