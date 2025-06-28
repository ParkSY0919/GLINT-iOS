//
//  Filterex.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/24/25.
//

import Foundation

struct Filterex: ResponseData {
    let id, category, title, description: String
    let files: [String]
    let price: Int
    let creator: UserInfo
    let filterValues: [String: Double]
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, category, title, description, files, price, creator
        case filterValues = "filter_values"
        case createdAt, updatedAt
    }
}
