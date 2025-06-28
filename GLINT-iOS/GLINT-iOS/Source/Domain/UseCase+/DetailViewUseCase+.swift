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
                let metadata = response.photoMetadata
                let presets = response.filterValues.toEntity()

                return (filter, profile, metadata, presets)
            },
            
            likeFilter: { filterID, likeStatus in
                return try await filterRepo.likeFilter(filterID, likeStatus)
            },
            
            createOrder: { filterID, filterPrice in
                let request = CreateOrderRequest(filter_id: filterID, total_price: filterPrice)
                return try await purchaseRepo.createOrder(request)
            },
            
            orderInfo: {
                return try await purchaseRepo.orderInfo()
            },
            
            paymentValidation: { imp_uid in
                let request = PaymentValidationRequest(imp_uid: imp_uid)
                return try await purchaseRepo.paymentValidation(request)
            },
            
            paymentInfo: { order_code in
                let request = PaymentInfoRequest(order_code: order_code)
                let resposne = try await purchaseRepo.paymentInfo(request)
                print("paymentInfo resposne: \n\(resposne)")
                return resposne
            }
        )
    }()
    
}

