//
//  TodayFilterView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/21/25.
//

import SwiftUI
import NukeUI

struct TodayFilterView: View {
    @Binding var todayFilter: ResponseEntity.TodayFilter?
    let router: NavigationRouter<MainTabRoute>
    let onTryFilterTapped: () -> Void
    
    @State private var scrollOffset: CGFloat = 0
    
    private let backgroundGradient = Gradient(colors: [
        .clear,
        .black.opacity(0.2),
        .black.opacity(0.3),
        .black.opacity(0.4),
        .black.opacity(0.5),
        .black.opacity(0.7),
        .black.opacity(0.8),
        .black.opacity(0.9),
        .black.opacity(1.0)
    ])
    
    var body: some View {
        ZStack(alignment: .top) {
            backgroundImageView
            contentStackView
            tryButtonView
        }
        .frame(height: 555)
    }
}

// MARK: - Views
private extension TodayFilterView {
    @ViewBuilder
    var backgroundImageView: some View {
        LazyImage(url: URL(string: todayFilter?.filtered ?? "")) { state in
            lazyImageTransform(state) { image in
                GeometryReader { proxy in
                    let global = proxy.frame(in: .global)
                    let width = global.width
                    
                    image
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width, height: 555)
                        .clipped()
                        .overlay {
                            LinearGradient(
                                gradient: backgroundGradient,
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        }
                }
            }
        }
    }
    
    var contentStackView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
            smallTitleView
            largeTitleView
            descriptionView
            
            CategoryButtonsView(categories: DummyFilterAppData.categories)
                .padding(.top, 30)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
    }
    
    var smallTitleView: some View {
        Text("오늘의 필터 소개")
            .font(.pretendardFont(.body_medium, size: 13))
            .foregroundStyle(.gray60)
            .foregroundColor(.white.opacity(0.8))
    }
    
    var largeTitleView: some View {
        Text(todayFilter?.title ?? "")
            .font(.pointFont(.title, size: 32))
            .foregroundColor(.gray30)
            .lineLimit(2, reservesSpace: true)
            .padding(.top, 4)
            .padding(.bottom, 20)
    }
    
    var descriptionView: some View {
        Text(todayFilter?.description ?? "")
            .font(.pretendardFont(.caption, size: 12))
            .foregroundStyle(.gray60)
            .lineLimit(4, reservesSpace: true)
    }
    
    var tryButtonView: some View {
        HStack {
            Spacer()
            
            Button {
                onTryFilterTapped()
            } label: {
                Text("사용해보기")
                    .font(.pretendardFont(.caption_medium, size: 12))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.gray75.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .foregroundColor(.gray0)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 60)
        .padding(.trailing, 20)
    }
}

// MARK: - Preview
#Preview {
    TodayFilterView(
        todayFilter: .constant(nil),
        router: NavigationRouter<MainTabRoute>(),
        onTryFilterTapped: {
            print("필터 사용 버튼 탭됨")
        }
    )
}

