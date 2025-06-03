//
//  FilterDetailRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import Foundation

struct FilterDetailRepository {
    var filterDetail: (_ filterId: String) async throws -> FilterDetailResponse
}

extension FilterDetailRepository: NetworkServiceProvider {
    typealias E = FilterDetailEndPoint
    
    static let liveValue: FilterDetailRepository = {
        return FilterDetailRepository (
            filterDetail: { filterId in
                let endPoint = FilterDetailEndPoint.filterDetail(filterId: filterId)
                return try await Self.requestAsync(endPoint)
            }
        )
    }()
}
