//
//  BannerView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/21/25.
//

import SwiftUI

import Nuke

struct BannerView: View {
    let bannerEntities: [BannerEntity]?
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    private let imagePrefetcher = ImagePrefetcher()
    
    @State private var currentIndex = 0
    @State private var bannerEntitiesData: [BannerEntity] = []
    
    var body: some View {
        if !bannerEntitiesData.isEmpty {
            TabView(selection: $currentIndex) {
                ForEach(Array(bannerEntitiesData.enumerated()), id: \.offset) { index, banner in
                    bannerItem(for: banner)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(alignment: .bottomTrailing) {
                pageIndicator(totalCount: bannerEntitiesData.count)
            }
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentIndex = (currentIndex + 1) % bannerEntitiesData.count
                }
            }
            .padding(.horizontal, 20)
            .onAppear {
                setupBannerData()
            }
            .onChange(of: bannerEntities) { newBanners in
                setupBannerData()
            }
        } else {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 100)
                .padding(.horizontal, 20)
                .overlay {
                    Text("배너를 불러올 수 없습니다.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .onAppear {
                    setupBannerData()
                }
        }
    }
    
    private func setupBannerData() {
        guard let bannerEntities = bannerEntities, !bannerEntities.isEmpty else {
            self.bannerEntitiesData = []
            return
        }
        
        if self.bannerEntitiesData != bannerEntities {
            self.bannerEntitiesData = bannerEntities
            
            let imageUrls = bannerEntities.map { $0.bannerImageURL }
            let urls = imageUrls.compactMap { URL(string: $0) }
            
            if !urls.isEmpty {
                let requests = urls.map { ImageRequest(url: $0, priority: .veryHigh) }
                imagePrefetcher.startPrefetching(with: requests)
            }
            
            currentIndex = 0
        }
    }
    
    // bannerItem이 BannerResponse를 받도록 수정
    func bannerItem(for banner: BannerEntity) -> some View {
        GTLazyImageView(urlString: banner.bannerImageURL, priority: .veryHigh) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        }
        .background(Color.gray.opacity(0.1))
        .onTapGesture {
            handleBannerTap(payload: banner.payload)
        }
    }
    
    // pageIndicator가 총 개수를 받도록 수정
    func pageIndicator(totalCount: Int) -> some View {
        Text("\(currentIndex + 1) / \(totalCount)")
            .font(.caption2)
            .padding(EdgeInsets(top: 3, leading: 6, bottom: 3, trailing: 6))
            .background(.black.opacity(0.5))
            .foregroundColor(.white)
            .clipShape(Capsule())
            .padding(10)
    }
    
    // handleBannerTap이 PayloadResponse를 받도록 수정
    func handleBannerTap(payload: PayloadResponse) {
        // TODO: payload의 type과 value를 사용하여 실제 동작 구현
        print("\(Strings.Main.Log.bannerTapped) - Type: \(payload.type), Value: \(payload.value)")
    }
}
