//
//  FilterSummaryResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/20/25.
//

import Foundation

struct FilterSummaryResponse: ResponseData {
    let filterID, title, description: String
    let category: String?
    let files: [String]
    let creator: UserInfoResponse
    let isLiked: Bool
    let likeCount, buyerCount: Int
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case filterID = "filter_id"
        case category, title, description, files, creator
        case isLiked = "is_liked"
        case likeCount = "like_count"
        case buyerCount = "buyer_count"
        case createdAt, updatedAt
    }
}
