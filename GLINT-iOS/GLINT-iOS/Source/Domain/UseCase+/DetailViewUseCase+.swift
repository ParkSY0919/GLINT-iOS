//
//  DetailViewUseCase+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import Foundation

extension DetailViewUseCase {
    static let liveValue: DetailViewUseCase = {
        let keychain: KeychainManager = .shared
        let filterRepo: FilterRepository = .liveValue
        let filterDetailRepo: FilterDetailRepository = .liveValue
        let purchaseRepo: PurchaseRepository = .liveValue
        let chatRepo: ChatRepository = .liveValue
        
        return DetailViewUseCase (
            filterDetail: { filterID in
                let response = try await filterDetailRepo.filterDetail(filterID)
                let filter = response.toFilterEntity()
                let profile = response.creator.toProfileEntity()
                let metadata = response.photoMetadata?.toEntity()
                let presets = response.filterValues.toEntity()
                let isMyPost = keychain.getUserId() == profile.userID

                return (filter, profile, metadata, presets, isMyPost)
            },
            
            likeFilter: { filterID, likeStatus in
                return try await filterRepo.likeFilter(filterID, likeStatus).likeStatus
            },
            
            deleteFilter: { filterID in
                return try await filterDetailRepo.deleteFilter(filterID)
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
            },
            
            postChats: { userID in
                return try await chatRepo.postChats(userID).roomID
            }
        )
    }()
    
}

