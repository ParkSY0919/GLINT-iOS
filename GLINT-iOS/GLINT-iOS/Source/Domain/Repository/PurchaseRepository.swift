//
//  PurchaseRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/24/25.
//

import Foundation

struct PurchaseRepository {
    var createOrder: (_ request: CreateOrderRequest) async throws -> CreateOrderResponse
    var orderInfo: () async throws -> OrderInfoResponse
    var paymentValidation: (_ request: PaymentValidationRequest) async throws -> PaymentValidationResponse
    var paymentInfo: (_ request: PaymentInfoRequest) async throws -> PaymentInfoResponse
}
