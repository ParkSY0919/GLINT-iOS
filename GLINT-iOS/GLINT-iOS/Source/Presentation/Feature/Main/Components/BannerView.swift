//
//  BannerView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/21/25.
//

import SwiftUI

struct BannerView: View {
    @State
    private var currentIndex = 0
    
    let items: [BannerItem]
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        contentView
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(alignment: .bottomTrailing) {
                pageIndicator()
            }
            .onReceive(timer) { _ in
                withAnimation(.default) {
                    currentIndex = (currentIndex + 1) % items.count
                }
            }
            .padding(.horizontal, 20)
    }
}

private extension BannerView {
    var contentView: some View {
        TabView(selection: $currentIndex) {
            ForEach(items.indices, id: \.self) { index in
                bannerItem(at: index)
            }
        }
    }
    
    func bannerItem(at index: Int) -> some View {
        Image(items[index].imageName)
            .resizable()
            .scaledToFill()
            .tag(index)
            .onTapGesture {
                handleBannerTap(at: index)
            }
    }
    
    func pageIndicator() -> some View {
        Text("\(currentIndex + 1) / \(items.count)")
            .font(.caption2)
            .padding(EdgeInsets(top: 3, leading: 6, bottom: 3, trailing: 6))
            .background(.black.opacity(0.5))
            .foregroundColor(.white)
            .clipShape(Capsule())
            .padding(10)
    }
    
    func handleBannerTap(at index: Int) {
        //TODO: 추후 배너 연결
        print("배너 \(index + 1) 탭됨")
    }
}
