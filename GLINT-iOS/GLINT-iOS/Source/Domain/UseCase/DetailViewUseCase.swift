//
//  DetailViewUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/8/25.
//

import Foundation

struct DetailViewUseCase {
    var filterDetail: @Sendable (_ filterID: String) async throws -> (
        FilterEntity,
        ProfileEntity,
        PhotoMetadataEntity?,
        FilterValuesEntity,
        Bool
    )
    var likeFilter: @Sendable (_ filterID: String, _ likeStatus: Bool) async throws -> Bool //likeStatus 사용
    var deleteFilter: @Sendable (_ filterID: String) async throws -> ()
    var createOrder: @Sendable (_ filterID: String, _ filterPrice: Int) async throws -> String //orderCode 사용
    var orderInfo: @Sendable () async throws -> OrderInfoResponse
    var paymentValidation: @Sendable (_ impUid: String) async throws -> String //orderCode 사용
    var paymentInfo: @Sendable (_ orderCode: String) async throws -> (String?, String) //name, merchantUid 사용
}
