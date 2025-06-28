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
        PhotoMetadata?,
        FilterPresetsEntity
    )
    var likeFilter: @Sendable (_ filterID: String, _ likeStatus: Bool) async throws -> LikeFilterResponse
    var createOrder: @Sendable (_ filterID: String, _ filterPrice: Int) async throws -> CreateOrderResponse
    var orderInfo: @Sendable () async throws -> OrderInfoResponse
    var paymentValidation: @Sendable (_ imp_uid: String) async throws -> PaymentValidationResponse
    var paymentInfo: @Sendable (_ order_code: String) async throws -> PaymentInfoResponse
}
