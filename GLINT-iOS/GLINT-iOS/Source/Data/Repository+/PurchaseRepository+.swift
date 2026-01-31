//
//  PurchaseRepository+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/24/25.
//

import Foundation

extension PurchaseRepository {
    static let liveValue: PurchaseRepository = {
        let provider = NetworkService<PurchaseEndPoint>()

        return PurchaseRepository(
            //주문 생성
            createOrder: { filterID, totalPrice in
                let request = CreateOrderRequest(filter_id: filterID, total_price: totalPrice)
                let response: CreateOrderResponse = try await provider.request(.createOrder(request))
                return response.toEntity()
            },

            //주문 정보
            orderInfo: {
                let response: OrderInfoResponse = try await provider.request(.infoOrder)
                return response.toEntity()
            },

            //결제 영수증 검증
            paymentValidation: { impUid in
                let request = PaymentValidationRequest(impUid: impUid)
                let response: PaymentValidationResponse = try await provider.request(.paymentValidation(request))
                return response.toEntity()
            },

            //결제 영수증 조회
            paymentInfo: { orderCode in
                let request = PaymentInfoRequest(orderCode: orderCode)
                let response: PaymentInfoResponse = try await provider.request(.paymentInfo(request))
                return response.toEntity()
            }
        )
    }()
}
