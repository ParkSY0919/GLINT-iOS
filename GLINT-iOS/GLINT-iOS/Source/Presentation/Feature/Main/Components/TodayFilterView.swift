//
//  TodayFilterView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/21/25.
//

import SwiftUI

struct TodayFilterView: View {
    let filter: TodayFilter
    let router: NavigationRouter<MainTabRoute>
    
    var body: some View {
        ZStack(alignment: .top) {
            backgroundImageView()
            
            contentStackView()
            
            tryButtonView()
        }
        .frame(height: 555)
    }
    
    // MARK: - Background Image
    private func backgroundImageView() -> some View {
        Image(filter.backgroundImageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 555)
            .clipped()
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                    startPoint: .center,
                    endPoint: .bottom
                )
            )
    }
    
    // MARK: - Content Stack
    private func contentStackView() -> some View {
        VStack(alignment: .leading) {
            Spacer()
            smallTitleView()
            largeTitleView()
            descriptionView()
            CategoryButtonsView(categories: DummyFilterAppData.categories)
                .padding(.top, 41)
                .frame(maxWidth: .infinity)
        }
        
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
    
    private func smallTitleView() -> some View {
        Text(filter.smallTitle)
            .font(.pretendardFont(.body_medium, size: 13))
            .foregroundStyle(.gray60)
            .foregroundColor(.white.opacity(0.8))
    }
    
    private func largeTitleView() -> some View {
        Text(filter.largeTitle)
            .font(.pointFont(.title, size: 32))
            .foregroundColor(.gray30)
            .lineLimit(2, reservesSpace: true)
            .padding(.top, 4)
            .padding(.bottom, 20)
    }
    
    private func descriptionView() -> some View {
        Text(filter.description)
            .font(.pretendardFont(.caption, size: 12))
            .foregroundStyle(.gray60)
            .lineLimit(4, reservesSpace: true)
    }
    
    // MARK: - Try Button
    private func tryButtonView() -> some View {
        HStack {
            Spacer()
            Button {
                print("오늘의 필터 사용해보기 버튼 탭됨")
            } label: {
                Text("사용해보기")
                    .font(.pretendardFont(.caption_medium, size: 12))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.gray75).opacity(0.7)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .foregroundColor(.gray0)
            }
        }
        .padding(.top, 60)
        .padding(.trailing, 20)
    }
}

#Preview {
    TodayFilterView(filter: DummyFilterAppData.todayFilter, router: NavigationRouter<MainTabRoute>())
}

