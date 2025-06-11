//
//  CreateOrderDTO.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/11/25.
//

import Foundation

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

extension CreateOrderEntity.Request {
    func toDTO() -> CreateOrderDTO.Request {
        return .init(
            filter_id: filter_id,
            total_price: total_price
        )
    }
}
