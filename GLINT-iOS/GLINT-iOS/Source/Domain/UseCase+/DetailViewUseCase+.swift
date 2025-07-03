//
//  DetailViewUseCase+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import Foundation

extension DetailViewUseCase {
    static let liveValue: DetailViewUseCase = {
        let filterRepo: FilterRepository = .liveValue
        let filterDetailRepo: FilterDetailRepository = .liveValue
        let purchaseRepo: PurchaseRepository = .liveValue
        
        return DetailViewUseCase (
            filterDetail: { filterID in
                let response = try await filterDetailRepo.filterDetail(filterID)
                let filter = response.toFilterEntity()
                let profile = response.creator.toProfileEntity()
                let metadata = response.photoMetadata?.toEntity()
                let presets = response.filterValues.toEntity()

                return (filter, profile, metadata, presets)
            },
            
            likeFilter: { filterID, likeStatus in
                return try await filterRepo.likeFilter(filterID, likeStatus).likeStatus
            },
            
            createOrder: { filterID, filterPrice in
                let request = CreateOrderRequest(filter_id: filterID, total_price: filterPrice)
                return try await purchaseRepo.createOrder(request).orderCode
            },
            
            orderInfo: {
                return try await purchaseRepo.orderInfo()
            },
            
            paymentValidation: { impUid in
                let request = PaymentValidationRequest(impUid: impUid)
                let response = try await purchaseRepo.paymentValidation(request).orderItem.orderCode
                return response
            },
            
            paymentInfo: { orderCode in
                let request = PaymentInfoRequest(orderCode: orderCode)
                let response = try await purchaseRepo.paymentInfo(request)
                return (response.name, response.merchantUid)
            }
        )
    }()
    
}

