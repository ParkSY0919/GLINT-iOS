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
    let creator: UserInfoResponse
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
}
