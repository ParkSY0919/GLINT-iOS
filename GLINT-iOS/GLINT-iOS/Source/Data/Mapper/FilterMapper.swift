//
//  FilterMapper.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/2/25.
//

import Foundation

struct FilterMapper {
    static func map(from response: FilterDetailResponse) -> FilterEntity {
        let original = response.files.first
        let filtered = response.files.last
        
        return .init(
            id: response.filterID,
            category: response.category,
            title: response.title,
            introduction: nil,
            description: response.description,
            original: original?.imageURL,
            filtered: filtered?.imageURL,
            isDownloaded: response.isDownloaded,
            isLiked: response.isLiked,
            price: response.price,
            likeCount: response.likeCount,
            buyerCount: response.buyerCount,
            createdAt: response.createdAt,
            updatedAt: response.updatedAt
        )
    }
}
