//
//  DetailViewUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/8/25.
//

import Foundation

struct DetailViewUseCase {
    var filterDetail: @Sendable (_ filterID: String) async throws -> FilterDetailEntity
    var createOrder: @Sendable (_ request: CreateOrderEntity.Request) async throws -> CreateOrderEntity.Response
    var infoOrder: @Sendable () async throws -> OrderHistoryEntity.Response
    var paymentValidation: @Sendable (_ request: PaymentValidationEntity.Request) async throws -> PaymentValidationEntity.Response
}
