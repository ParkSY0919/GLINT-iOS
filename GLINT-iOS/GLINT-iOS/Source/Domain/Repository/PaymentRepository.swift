//
//  PaymentRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/11/25.
//

import Foundation

struct PaymentRepository {
    var paymentValidation: (_ request: PaymentValidationEntity.Request) async throws -> PaymentValidationEntity.Response
}

