//
//  TodayFilterEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/29/25.
//

import Foundation

struct TodayFilterResponseEntity: Codable {
    let filterID, title, introduction, description: String
    let files: [String]

    enum CodingKeys: String, CodingKey {
        case filterID = "filter_id"
        case title, introduction, description, files
    }
}
