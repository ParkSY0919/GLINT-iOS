//
//  TodayArtist.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/22/25.
//

import SwiftUI

struct TodayArtistView: View {
    let artist: Artist
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
        Image(artist.profileImage)
            .resizable()
            .scaledToFill()
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
        Text(artist.name)
            .font(.pointFont(.body, size: 20))
            .foregroundColor(.gray30)
    }
    
    private func artistNickname() -> some View {
        Text(artist.nickname)
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
        HStack(spacing: 12) {
            ForEach(artist.worksImage, id: \.self) { image in
                artistWorkImage(image: image)
            }
        }
    }
    
    private func artistWorkImage(image: ImageResource) -> some View {
        Image(image)
            .resizable()
            .scaledToFill()
            .frame(width: 120, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    // MARK: - Artist Tags Section
    private func artistTagsSection() -> some View {
        HStack {
            ForEach(artist.tags, id: \.self) { tag in
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
        Text(artist.introductionTitle)
            .font(.pointFont(.body, size: 14))
            .foregroundColor(.gray60)
    }
    
    private func artistIntroductionBody() -> some View {
        Text(artist.introductionBody)
            .font(.pretendardFont(.caption, size: 12))
            .foregroundColor(.gray60)
    }
}

#Preview {
    TodayArtistView(artist: DummyFilterAppData.todayArtist, router: NavigationRouter<MainTabRoute>())
        .preferredColorScheme(.dark)
}

