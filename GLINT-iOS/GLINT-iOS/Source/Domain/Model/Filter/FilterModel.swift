//
//  FilterModel.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/2/25.
//

import Foundation

struct FilterModel: Codable {
    let filterID, category, title, description: String
    let original, filtered: String?
    let price: Int?
    let isLiked: Bool
    let isDownloaded: Bool?
    let likeCount, buyerCount: Int
    let createdAt, updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case filterID = "filter_id"
        case isLiked = "is_liked"
        case isDownloaded = "is_downloaded"
        case likeCount = "like_count"
        case buyerCount = "buyer_count"
        case category, title, description, original, filtered, price, createdAt, updatedAt
    }
}
