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
        let author: UserInfoModel
        let filters: [FilterEntity]
    }
}


//MARK: - FilterEntity
struct FilterEntity: Codable, Identifiable {
    static func == (lhs: FilterEntity, rhs: FilterEntity) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: String
    let category, title, description: String
    let original: String?
    let filtered: String?
    let creator: UserInfoModel
    let isLiked: Bool
    let likeCount, buyerCount: Int
    let createdAt, updatedAt: String
}

extension ResponseEntity.TodayAuthor {
    
    
    
}
