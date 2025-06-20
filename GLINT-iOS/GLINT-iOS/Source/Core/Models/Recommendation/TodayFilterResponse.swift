//
//  TodayFilterResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/19/25.
//

import Foundation

struct TodayFilterResponse: Codable {
    let filterID, title, introduction, description: String
    let files: [String]
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case filterID = "filter_id"
        case title, introduction, description, files, createdAt, updatedAt
    }
    
    func toFilterEntity() -> FilterEntity {
        let original = self.files.first
        let filtered = self.files.last
        
        return .init(
            id: filterID,
            category: nil,
            title: title,
            introduction: introduction,
            description: description,
            original: original?.imageURL,
            filtered: filtered?.imageURL,
            isDownloaded: nil,
            isLiked: nil,
            price: nil,
            likeCount: nil,
            buyerCount: nil,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}


