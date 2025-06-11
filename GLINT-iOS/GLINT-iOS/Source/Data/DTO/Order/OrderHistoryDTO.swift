//
//  OrderHistoryDTO.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/11/25.
//

import Foundation

enum OrderHistoryDTO {
    struct Response: ResponseData {
        let data: [Datum]
        
        func toEntity() -> OrderHistoryEntity.Response {
            return .init(data: data)
        }
    }
}

struct Datum: Codable {
    let orderID, orderCode: String
    let filter: Filterex
    let paidAt, createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case orderID = "order_id"
        case orderCode = "order_code"
        case filter, paidAt, createdAt, updatedAt
    }
}

// MARK: - Filter
struct Filterex: Codable {
    let id, category, title, description: String
    let files: [String]
    let price: Int
    let creator: Creator
    let filterValues: [String: Double]
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, category, title, description, files, price, creator
        case filterValues = "filter_values"
        case createdAt, updatedAt
    }
}

// MARK: - Creator
struct Creator: Codable {
    let userID, nick, name, introduction: String
    let profileImage: String
    let hashTags: [String]

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, name, introduction, profileImage, hashTags
    }
}
