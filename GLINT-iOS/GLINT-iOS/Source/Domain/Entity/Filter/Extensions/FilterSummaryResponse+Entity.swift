//
//  FilterSummaryResponse+Entity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/3/25.
//

import Foundation

extension FilterSummaryResponse {
    func toEntity() -> FilterEntity {
        var newFiles = [""]
        func toImageString() {
            for index in 0..<files.count {
                newFiles.append(files[index].imageURL)
            }
        }
        
        toImageString()
        let original = self.files.first
        let filtered = self.files.last
        
        return FilterEntity(
            id: self.filterID,
            category: self.category,
            title: self.title,
            introduction: nil,
            description: self.description,
            original: original?.imageURL,
            filtered: filtered?.imageURL,
            isDownloaded: nil,
            isLiked: self.isLiked,
            price: nil,
            likeCount: self.likeCount,
            buyerCount: self.buyerCount,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
