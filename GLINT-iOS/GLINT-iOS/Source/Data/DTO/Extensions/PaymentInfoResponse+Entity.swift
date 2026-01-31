//
//  PaymentInfoResponse+Entity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

extension PaymentInfoResponse {
    func toEntity() -> PaymentInfoEntity {
        return .init(
            impUid: self.impUid,
            merchantUid: self.merchantUid,
            payMethod: self.payMethod,
            cardName: self.cardName,
            amount: self.amount,
            currency: self.currency,
            status: self.status,
            paidAt: self.paidAt,
            receiptURL: self.receiptURL
        )
    }
}
