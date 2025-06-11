//
//  OrderRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/11/25.
//

import Foundation

struct OrderRepository {
    var createOrder: (_ request: CreateOrderEntity.Request) async throws -> CreateOrderEntity.Response
    var infoOrder: () async throws -> OrderHistoryEntity.Response
}
