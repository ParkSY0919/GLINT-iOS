//
//  BannerView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/21/25.
//

import SwiftUI

struct BannerView: View {
    let items: [BannerItem]
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect() // 10초 타이머

    var body: some View {
        TabView(selection: $currentIndex) { // 페이징 TabView 사용
            ForEach(items.indices, id: \.self) { index in
                Image(items[index].imageName)
                    .resizable()
                    .scaledToFill()
                    .tag(index)
                    .onTapGesture {
                        print("배너 \(index + 1) 탭됨")
                    }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(alignment: .bottomTrailing) {
            Text("\(currentIndex + 1) / \(items.count)")
                .font(.caption2)
                .padding(EdgeInsets(top: 3, leading: 6, bottom: 3, trailing: 6))
                .background(.black.opacity(0.5))
                .foregroundColor(.white)
                .clipShape(Capsule())
                .padding(10)
        }
        .onReceive(timer) { _ in
            withAnimation(.default) {
                currentIndex = (currentIndex + 1) % items.count // 다음 인덱스로 (순환)
            }
        }
    }
}

#Preview {
    BannerView(items: DummyFilterAppData.bannerItems)
        .padding()
}

