//
//  PaymentValidationEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/11/25.
//

import Foundation

enum PaymentValidationEntity {
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
    }
}
