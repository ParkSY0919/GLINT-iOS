//
//  BannerView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/21/25.
//

import SwiftUI

struct BannerView: View {
    let items: [BannerItem]
    let router: NavigationRouter<MainTabRoute>
    
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        bannerContainer()
    }
    
    // MARK: - Container
    private func bannerContainer() -> some View {
        bannerTabView()
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(alignment: .bottomTrailing) {
                pageIndicator()
            }
            .onReceive(timer) { _ in
                handleTimerUpdate()
            }
            .padding(.horizontal, 20)
    }
    
    // MARK: - Banner TabView
    private func bannerTabView() -> some View {
        TabView(selection: $currentIndex) {
            ForEach(items.indices, id: \.self) { index in
                bannerItem(at: index)
            }
        }
    }
    
    // MARK: - Banner Item
    private func bannerItem(at index: Int) -> some View {
        Image(items[index].imageName)
            .resizable()
            .scaledToFill()
            .tag(index)
            .onTapGesture {
                handleBannerTap(at: index)
            }
    }
    
    // MARK: - Page Indicator
    private func pageIndicator() -> some View {
        Text("\(currentIndex + 1) / \(items.count)")
            .font(.caption2)
            .padding(EdgeInsets(top: 3, leading: 6, bottom: 3, trailing: 6))
            .background(.black.opacity(0.5))
            .foregroundColor(.white)
            .clipShape(Capsule())
            .padding(10)
    }
    
    // MARK: - Actions
    private func handleBannerTap(at index: Int) {
        print("배너 \(index + 1) 탭됨")
    }
    
    private func handleTimerUpdate() {
        withAnimation(.default) {
            currentIndex = (currentIndex + 1) % items.count
        }
    }
}
//#Preview {
//    BannerView(items: DummyFilterAppData.bannerItems, router: NavigationRouter<MainTabRoute>())
////        .padding()
//}

