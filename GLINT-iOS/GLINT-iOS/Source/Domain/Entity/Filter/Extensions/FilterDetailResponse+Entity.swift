//
//  FilterDetailResponse+Entity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/3/25.
//

import Foundation

extension FilterDetailResponse {
    func toFilterEntity() -> FilterEntity {
        let original = self.files.first?.imageURL
        let filtered = self.files.last?.imageURL
        
        return .init(
            id: self.filterID,
            category: self.category,
            title: self.title,
            introduction: nil,
            description: self.description,
            original: original,
            filtered: filtered,
            isDownloaded: self.isDownloaded,
            isLiked: self.isLiked,
            price: self.price,
            likeCount: self.likeCount,
            buyerCount: self.buyerCount,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
