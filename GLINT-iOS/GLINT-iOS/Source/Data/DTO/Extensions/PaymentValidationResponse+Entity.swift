//
//  PaymentValidationResponse+Entity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

extension PaymentValidationResponse {
    func toEntity() -> PaymentValidationEntity {
        let orderItem = self.orderItem
        let filter = orderItem.filter

        return .init(
            paymentID: self.paymentID,
            orderItem: OrderItemEntity(
                orderItemID: orderItem.orderID,
                filter: FilterEntity(
                    id: filter.id,
                    category: filter.category,
                    title: filter.title,
                    introduction: nil,
                    description: filter.description,
                    original: filter.files.first,
                    filtered: filter.files.last,
                    isDownloaded: nil,
                    isLiked: nil,
                    price: filter.price,
                    likeCount: nil,
                    buyerCount: nil,
                    createdAt: filter.createdAt,
                    updatedAt: filter.updatedAt
                ),
                price: filter.price,
                createdAt: orderItem.createdAt,
                updatedAt: orderItem.updatedAt
            ),
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
