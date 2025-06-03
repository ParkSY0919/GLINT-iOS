//
//  FilterDetailRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import Foundation

struct FilterDetailRepository {
    var filterDetail: (_ request: FilterDetailRequest) async throws -> FilterDetailResponse
}

extension FilterDetailRepository: NetworkServiceProvider {
    typealias E = FilterDetailEndPoint
    
    static let liveValue: FilterDetailRepository = {
        return FilterDetailRepository (
            filterDetail: { request in
                let endPoint = FilterDetailEndPoint.filterDetail(request)
                return try await Self.requestAsync(endPoint)
            }
        )
    }()
}
