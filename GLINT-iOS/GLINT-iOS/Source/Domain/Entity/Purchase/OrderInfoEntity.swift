//
//  OrderInfoEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

struct OrderInfoEntity {
    let orders: [OrderDetailEntity]
}

struct OrderDetailEntity {
    let orderID: String
    let orderCode: String
    let totalPrice: Int
    let status: String
    let createdAt: String
    let updatedAt: String
    let items: [OrderItemEntity]
}

struct OrderItemEntity {
    let orderItemID: String
    let filter: FilterEntity
    let price: Int
    let createdAt: String
    let updatedAt: String
}
