//
//  CreateOrderResponse+Entity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

extension CreateOrderResponse {
    func toEntity() -> OrderEntity {
        return .init(
            orderID: self.orderID,
            orderCode: self.orderCode,
            totalPrice: self.totalPrice,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
