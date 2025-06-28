//
//  CreateOrderResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/23/25.
//

import Foundation

struct CreateOrderResponse: ResponseData {
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
