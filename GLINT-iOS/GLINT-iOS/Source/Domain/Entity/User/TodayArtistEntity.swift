//
//  TodayArtistEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/24/25.
//

import Foundation

struct TodayArtistEntity {
    let author: TodayAuthorEntity
    let filters: [TodayArtistFilterEntity]
}

extension TodayArtistEntity {
    
    //MARK: - Author
    struct TodayAuthorEntity {
        let userID, nick, name, introduction: String
        let description: String?
        let profileImage: String
        let hashTags: [String]
    }
    
    //MARK: - TodayArtistFilter
    struct TodayArtistFilterEntity {
        let filterID, category, title, description: String
        let files: [String]
        let creator: TodayArtistEntity
        let isLiked: Bool
        let likeCount, buyerCount: Int
        let createdAt, updatedAt: String
    }
    
}
