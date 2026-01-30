//
//  TodayFilterResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/19/25.
//

import Foundation

struct TodayFilterResponse: ResponseData {
    let filterID, title, introduction, description: String
    let files: [String]
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case filterID = "filter_id"
        case title, introduction, description, files, createdAt, updatedAt
    }
}
