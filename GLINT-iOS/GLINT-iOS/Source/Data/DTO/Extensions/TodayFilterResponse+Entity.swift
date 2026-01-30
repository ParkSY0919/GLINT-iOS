//
//  TodayFilterResponse+Entity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/3/25.
//

import Foundation

extension TodayFilterResponse {
    func toEntity() -> FilterEntity {
        let original = self.files.first
        let filtered = self.files.last
        
        return .init(
            id: filterID,
            category: nil,
            title: title,
            introduction: introduction,
            description: description,
            original: original?.imageURL,
            filtered: filtered?.imageURL,
            isDownloaded: nil,
            isLiked: nil,
            price: nil,
            likeCount: nil,
            buyerCount: nil,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
