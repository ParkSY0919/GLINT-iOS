//
//  TodayFilterResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/29/25.
//

import Foundation

// MARK: - TodayFilterResponse
struct TodayFilterResponse: Codable {
    let filterID, title, introduction, description: String
    let files: [String]
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case filterID = "filter_id"
        case title, introduction, description, files, createdAt, updatedAt
    }
}

extension TodayFilterResponse {
    func toEntity() -> TodayFilterResponseEntity {
        let original = self.files.first
        let filtered = self.files.last
        
        return .init(
            filterID: filterID,
            title: title,
            introduction: introduction,
            description: description,
            original: original?.imageURL,
            filtered: filtered?.imageURL
        )
    }
}

