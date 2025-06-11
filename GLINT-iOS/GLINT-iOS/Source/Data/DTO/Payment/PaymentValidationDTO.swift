//
//  PaymentValidationDTO.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/11/25.
//

import Foundation

enum PaymentValidationDTO {
    struct Request: RequestData {
        let imp_uid: String
    }
    
    struct Response: ResponseData {
        let paymentID: String
        let orderItem: OrderItem
        let createdAt, updatedAt: String

        enum CodingKeys: String, CodingKey {
            case paymentID = "payment_id"
            case orderItem = "order_item"
            case createdAt, updatedAt
        }
        
        func toEntity() -> PaymentValidationEntity.Response {
            return .init(
                paymentID: paymentID,
                orderItem: orderItem,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
        }
    }
}

extension PaymentValidationEntity.Request {
    func toDTO() -> PaymentValidationDTO.Request {
        return .init(imp_uid: imp_uid)
    }
}

// MARK: - OrderItem
struct OrderItem: Codable {
    let orderID, orderCode: String
    let filter: FilterPayment
    let paidAt, createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case orderID = "order_id"
        case orderCode = "order_code"
        case filter, paidAt, createdAt, updatedAt
    }
}

// MARK: - Filter
struct FilterPayment: Codable {
    let id, category, title, description: String
    let files: [String]
    let price: Int
    let creator: CreatorPayment
    let filterValues: [String: Double]?
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, category, title, description, files, price, creator
        case filterValues = "filter_values"
        case createdAt, updatedAt
    }
}

// MARK: - Creator
struct CreatorPayment: Codable {
    let userID, nick, name, introduction: String
    let profileImage: String?
    let hashTags: [String]

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, name, introduction, profileImage, hashTags
    }
}
