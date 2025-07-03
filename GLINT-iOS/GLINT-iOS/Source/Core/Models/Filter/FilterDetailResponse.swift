//
//  FilterDetailResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/23/25.
//

import Foundation

struct FilterDetailResponse: ResponseData {
    let filterID: String
    let category: String
    let title: String
    let description: String
    let files: [String]
    let price: Int
    let creator: UserInfoResponse
    let photoMetadata: PhotoMetadataResponse?
    let filterValues: FilterValuesResponse
    let isLiked: Bool
    let isDownloaded: Bool
    let likeCount: Int
    let buyerCount: Int
    let comments: [CommentResponse]
    var createdAt: String = "9999-10-19T03:05:03.422Z"
    var updatedAt: String = "9999-10-19T03:05:03.422Z"

    enum CodingKeys: String, CodingKey {
        case filterID = "filter_id"
        case category, title, description, files, price, creator, photoMetadata, filterValues
        case isLiked = "is_liked"
        case isDownloaded = "is_downloaded"
        case likeCount = "like_count"
        case buyerCount = "buyer_count"
        case comments, createdAt, updatedAt
    }
    
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



