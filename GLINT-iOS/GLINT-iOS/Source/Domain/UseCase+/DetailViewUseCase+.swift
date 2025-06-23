//
//  DetailViewUseCase+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import Foundation

extension DetailViewUseCase {
    static let liveValue: DetailViewUseCase = {
        let filterRepo: FilterDetailRepository = .liveValue
        let orderRepo: OrderRepository = .value
        let paymentRepo: PaymentRepository = .value
        
        return DetailViewUseCase (
            filterDetail: { filterID in
                let response = try await filterRepo.filterDetail(filterID)
                let filter = response.toFilterEntity()
                let profile = response.creator.toProfileEntity()
                let metadata = response.photoMetadata
                let presets = response.filterValues.toEntity()
                
                return (filter, profile, metadata, presets)
            },
            
            createOrder: { request in
                return try await orderRepo.createOrder(request)
            },
            
            infoOrder: {
                return try await orderRepo.infoOrder()
            },
            
            paymentValidation: { request in
                return try await paymentRepo.paymentValidation(request)
            }
        )
    }()
    
}

