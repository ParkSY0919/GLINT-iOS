//
//  TodayArtist.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/22/25.
//

import SwiftUI

import NukeUI

struct TodayArtistView: View {
    @Binding var todayArtist: ResponseEntity.TodayAuthor?
    let router: NavigationRouter<MainTabRoute>
    
    var body: some View {
        artistContainer()
    }
    
    // MARK: - Container
    private func artistContainer() -> some View {
        VStack(alignment: .leading) {
            sectionTitle()
            artistProfileSection()
            artistWorksScrollView()
            artistTagsSection()
            artistIntroductionSection()
        }
    }
    
    // MARK: - Section Title
    private func sectionTitle() -> some View {
        Text("오늘의 작가 소개")
            .font(.pretendardFont(.body_bold, size: 16))
            .padding(.leading, 20)
            .foregroundColor(.gray60)
            
    }
    
    // MARK: - Artist Profile Section
    private func artistProfileSection() -> some View {
        HStack(spacing: 12) {
            artistProfileImage()
            artistNameSection()
        }
        .padding(.top, 14)
        .padding(.leading, 20)
    }
    
    private func artistProfileImage() -> some View {
        let imageUrlString = todayArtist?.author.profileImage ?? ""
        
        return LazyImage(url: URL(string: imageUrlString)) { state in
            lazyImageTransform(state) { image in
                image.aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(Circle())
    }
    
    private func artistNameSection() -> some View {
        VStack(alignment: .leading) {
            artistName()
            artistNickname()
        }
    }
    
    private func artistName() -> some View {
        Text(todayArtist?.author.name ?? "")
            .font(.pointFont(.body, size: 20))
            .foregroundColor(.gray30)
    }
    
    private func artistNickname() -> some View {
        Text(todayArtist?.author.nick ?? "")
            .font(.pretendardFont(.body_medium, size: 16))
            .foregroundColor(.gray75)
    }
    
    // MARK: - Artist Works Scroll View
    private func artistWorksScrollView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            artistWorksHorizontalStack()
        }
        .frame(height: 80)
        .padding(.top, 10)
        .padding(.horizontal, 20)
    }
    
    private func artistWorksHorizontalStack() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                if let todayArtist = todayArtist {
                    ForEach(todayArtist.filters, id: \.id) { filter in
                        LazyImage(url: URL(string: filter.filtered ?? "")) { state in
                            lazyImageTransform(state) { image in
                                image.aspectRatio(contentMode: .fill)
                            }
                        }
                        .frame(width: 120, height: 80)
                        .clipRectangle(8)
                        .clipped()
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    
    // MARK: - Artist Tags Section
    private func artistTagsSection() -> some View {
        HStack {
            ForEach(todayArtist?.author.hashTags ?? [], id: \.self) { tag in
                artistTag(tag: tag)
            }
        }
        .padding(.leading, 20)
        .padding(.top, 10)
    }
    
    private func artistTag(tag: String) -> some View {
        Text(tag)
            .font(.pointFont(.caption, size: 10))
            .foregroundColor(.gray60)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.quaternary)
            .clipShape(Capsule())
    }
    
    // MARK: - Artist Introduction Section
    private func artistIntroductionSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            artistIntroductionTitle()
            artistIntroductionBody()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private func artistIntroductionTitle() -> some View {
        Text(todayArtist?.author.introduction ?? "")
            .font(.pointFont(.body, size: 14))
            .foregroundColor(.gray60)
    }
    
    private func artistIntroductionBody() -> some View {
        Text(todayArtist?.author.description ?? "")
            .font(.pretendardFont(.caption, size: 12))
            .foregroundColor(.gray60)
    }
}

//#Preview {
//    TodayArtistView(artist: DummyFilterAppData.todayArtist, router: NavigationRouter<MainTabRoute>())
//        .preferredColorScheme(.dark)
//}

