//
//  OrderItemResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/24/25.
//

import Foundation

struct OrderItemResponse: ResponseData {
    let orderID, orderCode: String
    let filter: FilterPaymentResponse
    let paidAt, createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case orderID = "order_id"
        case orderCode = "order_code"
        case filter, paidAt, createdAt, updatedAt
    }
}
