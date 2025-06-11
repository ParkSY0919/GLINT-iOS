//
//  CreateOrderEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/11/25.
//

import Foundation

enum CreateOrderEntity {
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
    }
}
