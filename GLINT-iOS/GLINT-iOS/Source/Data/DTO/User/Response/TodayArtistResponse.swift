//
//  TodayArtistResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/24/25.
//

import Foundation

// MARK: - TodayArtistResponse
struct TodayArtistResponse: Decodable {
    let author: TodayAuthor
    let filters: [TodayArtistFilter]
    
    func toEntity() -> TodayArtistEntity {
        return TodayArtistEntity(
            author: author.toEntity(),
            filters: filters.map { $0.toEntity() }
        )
    }
}

extension TodayArtistResponse {
    // MARK: - TodayAuthor
    struct TodayAuthor: Decodable {
        let userID, nick, name, introduction: String
        let description: String?
        let profileImage: String
        let hashTags: [String]

        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case nick, name, introduction, description, profileImage, hashTags
        }
        
        func toEntity() -> TodayArtistEntity.TodayAuthorEntity {
            return TodayArtistEntity.TodayAuthorEntity(
                userID: self.userID,
                nick: self.nick,
                name: self.name,
                introduction: self.introduction,
                description: self.description,
                profileImage: self.profileImage,
                hashTags: self.hashTags
            )
        }
    }
    
    // MARK: - TodayArtistFilter
    struct TodayArtistFilter: Decodable {
        let filterID, category, title, description: String
        let files: [String]
        let creator: TodayAuthor
        let isLiked: Bool
        let likeCount, buyerCount: Int
        let createdAt, updatedAt: String

        enum CodingKeys: String, CodingKey {
            case filterID = "filter_id"
            case category, title, description, files, creator
            case isLiked = "is_liked"
            case likeCount = "like_count"
            case buyerCount = "buyer_count"
            case createdAt, updatedAt
        }
        
        func toEntity() -> TodayArtistEntity.TodayArtistFilterEntity {
            return TodayArtistEntity.TodayArtistFilterEntity(
                filterID: self.filterID,
                category: self.category,
                title: self.title,
                description: self.description,
                files: self.files,
                creator: self.creator.toEntity(),
                isLiked: self.isLiked,
                likeCount: self.likeCount,
                buyerCount: self.buyerCount,
                createdAt: self.createdAt,
                updatedAt: self.updatedAt
            )
        }
    }
}

