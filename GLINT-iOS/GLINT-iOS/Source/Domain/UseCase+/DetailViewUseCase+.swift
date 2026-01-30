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
                let detailEntity = try await filterDetailRepo.filterDetail(filterID)
                let isMyPost = keychain.getUserId() == detailEntity.creator.userID

                return (detailEntity.filter, detailEntity.creator, detailEntity.photoMetadata, detailEntity.filterValues, isMyPost)
            },

            likeFilter: { filterID, likeStatus in
                return try await filterRepo.likeFilter(filterID, likeStatus).likeStatus
            },

            deleteFilter: { filterID in
                return try await filterDetailRepo.deleteFilter(filterID)
            },

            createOrder: { filterID, filterPrice in
                return try await purchaseRepo.createOrder(filterID, filterPrice).orderCode
            },

            orderInfo: {
                return try await purchaseRepo.orderInfo()
            },

            paymentValidation: { impUid in
                let entity = try await purchaseRepo.paymentValidation(impUid)
                return entity.orderItem.filter.id
            },

            paymentInfo: { orderCode in
                let entity = try await purchaseRepo.paymentInfo(orderCode)
                return (entity.cardName, entity.merchantUid)
            },

            createChatRoom: { userID in
                let entity = try await chatRepo.createChatRoom(userID)
                return entity.id
            }
        )
    }()

}

