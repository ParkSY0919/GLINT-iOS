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
                return try await provider.requestAsync(.createOrder(request))
            },
            
            //주문 정보
            orderInfo: {
                return try await provider.requestAsync(.infoOrder)
            },
            
            //결제 영수증 검증
            paymentValidation: { request in
                return try await provider.requestAsync(.paymentValidation((request)))
            },
            
            //결제 영수증 조회
            paymentInfo: { request in
                return try await provider.requestAsync(.paymentInfo((request)))
            }
        )
    }()
}
