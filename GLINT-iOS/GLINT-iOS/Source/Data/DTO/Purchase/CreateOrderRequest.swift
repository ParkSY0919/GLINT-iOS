//
//  CreateOrderRequest.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/23/25.
//

import Foundation

struct CreateOrderRequest: RequestData {
    let filter_id: String
    let total_price: Int
}
