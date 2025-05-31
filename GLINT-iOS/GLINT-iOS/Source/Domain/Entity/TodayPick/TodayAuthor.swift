//
//  TodayArtistEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/24/25.
//

import Foundation

//MARK: - TodayArtistEntity
extension ResponseEntity {
    struct TodayAuthor {
        let author: AuthorEntity
        let filters: [FilterEntity]
    }
}

extension ResponseEntity.TodayAuthor {
    
    //MARK: - Author
    struct AuthorEntity {
        let userID, nick, name, introduction: String
        let description: String?
        let profileImage: String
        let hashTags: [String]
    }
    
    //MARK: - FilterEntity
    struct FilterEntity {
        let filterID, category, title, description: String
        let files: [String]
        let creator: AuthorEntity
        let isLiked: Bool
        let likeCount, buyerCount: Int
        let createdAt, updatedAt: String
    }
    
}
