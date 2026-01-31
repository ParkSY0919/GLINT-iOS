//
//  OrderInfoResponse+Entity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

extension OrderInfoResponse {
    func toEntity() -> OrderInfoEntity {
        return .init(
            orders: self.data.map { datum in
                OrderDetailEntity(
                    orderID: datum.orderID,
                    orderCode: datum.orderCode,
                    totalPrice: datum.filter.price,
                    status: "completed",
                    createdAt: datum.createdAt,
                    updatedAt: datum.updatedAt,
                    items: []
                )
            }
        )
    }
}
