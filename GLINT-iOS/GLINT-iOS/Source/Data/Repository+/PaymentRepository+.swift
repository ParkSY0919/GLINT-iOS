//
//  PaymentRepository+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/11/25.
//

import Foundation

extension PaymentRepository {
    static let value: PaymentRepository = {
        let provider = NetworkService<PaymentEndPoint>()
        
        return PaymentRepository(
            paymentValidation: { request in
                let request = request.toDTO()
                let response: PaymentValidationDTO.Response = try await provider.requestAsync(.paymentValidation((request)))
                return response.toEntity()
            }
        )
    }()
}
