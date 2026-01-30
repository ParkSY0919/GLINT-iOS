//
//  PaymentInfoEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

struct PaymentInfoEntity {
    let impUid: String
    let merchantUid: String
    let payMethod: String?
    let cardName: String?
    let amount: Int
    let currency: String
    let status: String
    let paidAt: String?
    let receiptURL: String?
}
