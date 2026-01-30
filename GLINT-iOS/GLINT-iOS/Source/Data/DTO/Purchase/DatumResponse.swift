//
//  DatumResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/24/25.
//

import Foundation

struct DatumResponse: ResponseData {
    let orderID, orderCode: String
    let filter: FilterexResponse
    let paidAt, createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case orderID = "order_id"
        case orderCode = "order_code"
        case filter, paidAt, createdAt, updatedAt
    }
}
