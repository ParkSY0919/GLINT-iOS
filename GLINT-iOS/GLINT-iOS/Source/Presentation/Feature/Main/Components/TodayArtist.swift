//
//  TodayArtist.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/22/25.
//

import SwiftUI

import NukeUI

import SwiftUI
import NukeUI

struct TodayArtistView: View {
    let author: ProfileEntity?
    let filters: [FilterEntity]?
    let onTapWorksItem: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleSection
            contentView
        }
    }
}

private extension TodayArtistView {
    var titleSection: some View {
        Text("오늘의 작가 소개")
            .font(.pretendardFont(.body_bold, size: 16))
            .padding(.leading, 20)
            .foregroundColor(.gray60)
    }
    
    @ViewBuilder
    var contentView: some View {
        if let author = author {
            profileSection(author)
            worksSection
            tagsSection(author)
            introductionSection(author)
        } else {
            StateViewBuilder.emptyStateView(message: "작가 정보를 불러올 수 없습니다")
        }
    }
    
    func profileSection(_ author: ProfileEntity) -> some View {
        HStack(spacing: 12) {
            if let url = author.profileImageURL {
                artistProfileImage(imageUrlString: url)
            }
            if let name = author.name,
               let nick = author.nick {
                artistNameSection(name: name, nick: nick)
            }
        }
        .padding(.top, 14)
        .padding(.leading, 20)
    }
    
    func artistProfileImage(imageUrlString: String) -> some View {
        LazyImage(url: URL(string: imageUrlString)) { state in
            lazyImageTransform(state) { image in
                image.aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(Circle())
    }
    
    func artistNameSection(name: String, nick: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            artistName(name: name)
            artistNickname(nick: nick)
        }
    }
    
    func artistName(name: String) -> some View {
        Text(name)
            .font(.pointFont(.body, size: 20))
            .foregroundColor(.gray30)
    }
    
    func artistNickname(nick: String) -> some View {
        Text(nick)
            .font(.pretendardFont(.body_medium, size: 16))
            .foregroundColor(.gray75)
    }
    
    @ViewBuilder
    var worksSection: some View {
        if let filter = filters, !filter.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(filter, id: \.id) { filterItem in
                        artistWorkItem(filterItem)
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 80)
            .padding(.top, 10)
        } else {
            StateViewBuilder.emptyStateView(message: "대표 작품을 불러올 수 없습니다")
        }
    }
    
    func artistWorkItem(_ filterItem: FilterEntity) -> some View {
        return LazyImage(url: URL(string: filterItem.filtered ?? "")) { state in
            lazyImageTransform(state) { image in
                image.aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: 120, height: 80)
        .clipRectangle(8)
        .clipped()
        .onTapGesture {
            onTapWorksItem(filterItem.id)
        }
    }
    
    @ViewBuilder
    func tagsSection(_ author: ProfileEntity) -> some View {
        let tags = author.hashTags ?? []
        if !tags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        artistTag(tag: tag)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 10)
        }
    }
    
    func artistTag(tag: String) -> some View {
        Text(tag)
            .font(.pointFont(.caption, size: 10))
            .foregroundColor(.gray60)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.quaternary)
            .clipShape(Capsule())
    }
    
    @ViewBuilder
    func introductionSection(_ author: ProfileEntity) -> some View {
        if let introduction = author.introduction,
           let description = author.description {
            VStack(alignment: .leading, spacing: 12) {
                if !introduction.isEmpty {
                    artistIntroductionTitle(content: introduction)
                }
                if !description.isEmpty {
                    artistIntroductionBody(content: description)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    func artistIntroductionTitle(content: String) -> some View {
        Text(content)
            .font(.pointFont(.body, size: 14))
            .foregroundColor(.gray60)
    }
    
    func artistIntroductionBody(content: String) -> some View {
        Text(content)
            .font(.pretendardFont(.caption, size: 12))
            .foregroundColor(.gray60)
            .lineLimit(nil)
    }
}
