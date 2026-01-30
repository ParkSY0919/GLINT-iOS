//
//  PurchaseRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/24/25.
//

import Foundation

struct PurchaseRepository {
    var createOrder: (_ filterID: String, _ totalPrice: Int) async throws -> OrderEntity
    var orderInfo: () async throws -> OrderInfoEntity
    var paymentValidation: (_ impUid: String) async throws -> PaymentValidationEntity
    var paymentInfo: (_ orderCode: String) async throws -> PaymentInfoEntity
}
