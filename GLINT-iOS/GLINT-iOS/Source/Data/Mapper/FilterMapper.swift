//
//  FilterMapper.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/2/25.
//

import Foundation

struct FilterMapper {
    static func map(from response: FilterDetailResponse) -> FilterModel {
        let original = response.files.first
        let filtered = response.files.last
        
        return .init(
            filterID: response.filterID,
            category: response.category,
            title: response.title,
            description: response.description,
            original: original?.imageURL,
            filtered: filtered?.imageURL,
            price: response.price,
            isLiked: response.isLiked,
            isDownloaded: response.isDownloaded,
            likeCount: response.likeCount,
            buyerCount: response.buyerCount,
            createdAt: response.createdAt,
            updatedAt: response.updatedAt
        )
    }
}
