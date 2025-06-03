//
//  FilterDetailResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import Foundation

struct FilterDetailResponse: ResponseData {
    let filterID, category, title, description: String
    let files: [String]
    let price: Int
    let creator: AuthorResponse
    let photoMetadata: PhotoMetadataResponse
    let filterValues: [String: Double]
    let isLiked, isDownloaded: Bool
    let likeCount, buyerCount: Int
    let comments: [FilterDetailCommentResponse]
    let createdAt, updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case filterID = "filter_id"
        case category, title, description, files, price, creator, photoMetadata, filterValues
        case isLiked = "is_liked"
        case isDownloaded = "is_downloaded"
        case likeCount = "like_count"
        case buyerCount = "buyer_count"
        case comments, createdAt, updatedAt
    }
    
    func toEntity() -> FilterDetailEntity {
        return .init(
            filter: FilterMapper.map(from: self),
            author: UserInfoMapper.map(from: self.creator),
            photoMetadata: PhotoMetadataMapper.map(from: self.photoMetadata),
            filterValues: FilterPresetsMapper.map(from: self.filterValues)
        )
    }
}








