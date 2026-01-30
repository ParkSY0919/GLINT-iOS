//
//  FilterResponse+Entity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/3/25.
//

import Foundation

extension FilterResponse {
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
            category: self.category ?? "풍경",
            title: self.title,
            introduction: nil,
            description: self.description,
            original: original?.imageURL,
            filtered: filtered?.imageURL,
            isDownloaded: self.isDownloaded ?? false,
            isLiked: self.isLiked,
            price: self.price ?? 0,
            likeCount: self.likeCount,
            buyerCount: self.buyerCount,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
