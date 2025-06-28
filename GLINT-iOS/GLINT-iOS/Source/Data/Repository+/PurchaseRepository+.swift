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
            createOrder: { request in
                return try await provider.request(.createOrder(request))
            },
            
            //주문 정보
            orderInfo: {
                return try await provider.request(.infoOrder)
            },
            
            //결제 영수증 검증
            paymentValidation: { request in
                return try await provider.request(.paymentValidation((request)))
            },
            
            //결제 영수증 조회
            paymentInfo: { request in
                return try await provider.request(.paymentInfo((request)))
            }
        )
    }()
}
