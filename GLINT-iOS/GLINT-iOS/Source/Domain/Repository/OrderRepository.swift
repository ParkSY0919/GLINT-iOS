//
//  OrderRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/11/25.
//

import Foundation

struct OrderRepository {
    var createOrder: (_ request: CreateOrderEntity.Request) async throws -> CreateOrderEntity.Response
    var infoOrder: () async throws -> InfoOrderEntity.Response
}

enum CreateOrderEntity {
    struct Request: RequestData {
        let filter_id: String
        let total_price: Int
        
        func toDTO() -> CreateOrderDTO.Request {
            return .init(
                filter_id: filter_id,
                total_price: total_price
            )
        }
    }
    
    struct Response: ResponseData {
        let orderID, orderCode: String
            let totalPrice: Int
            let createdAt, updatedAt: String

        enum CodingKeys: String, CodingKey {
            case orderID = "order_id"
            case orderCode = "order_code"
            case totalPrice = "total_price"
            case createdAt, updatedAt
        }
    }
}

enum CreateOrderDTO {
    struct Request: RequestData {
        let filter_id: String
        let total_price: Int
    }
    
    struct Response: ResponseData {
        let orderID, orderCode: String
            let totalPrice: Int
            let createdAt, updatedAt: String

        enum CodingKeys: String, CodingKey {
            case orderID = "order_id"
            case orderCode = "order_code"
            case totalPrice = "total_price"
            case createdAt, updatedAt
        }
        
        func toEntity() -> CreateOrderEntity.Response {
            return .init(
                orderID: orderID,
                orderCode: orderCode,
                totalPrice: totalPrice,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
        }
    }
}

enum InfoOrderEntity {
    struct Response: ResponseData {
        let data: [Datum]
    }
}

enum InfoOrderDTO {
    struct Response: ResponseData {
        let data: [Datum]
        
        func toEntity() -> InfoOrderEntity.Response {
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
