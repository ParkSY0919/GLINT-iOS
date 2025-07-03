//
//  FilterResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/19/25.
//

import Foundation

struct FilterResponse: ResponseData {
    let filterID, title, description: String
    let category: String?
    let files: [String]
    let creator: ProfileEntity
    let isLiked: Bool
    let likeCount, buyerCount: Int
    let createdAt, updatedAt: String
    let isDownloaded: Bool?
    let price: Int?

    enum CodingKeys: String, CodingKey {
        case filterID = "filter_id"
        case category, title, description, files, creator, price
        case isLiked = "is_liked"
        case likeCount = "like_count"
        case buyerCount = "buyer_count"
        case isDownloaded = "is_downloaded"
        case createdAt, updatedAt
    }
    
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
