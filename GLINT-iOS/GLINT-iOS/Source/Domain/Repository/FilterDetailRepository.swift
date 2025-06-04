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

extension FilterDetailRepository {
    static func create<T: NetworkServiceInterface>(networkService: T.Type)
    -> FilterDetailRepository where T.E == FilterDetailEndPoint {
        return .init(filterDetail: {
            let endpoint = FilterDetailEndPoint.filterDetail(filterId: $0)
            return try await networkService.requestAsync(endpoint)
        })
    }
}

extension FilterDetailRepository {
    static let liveValue: FilterDetailRepository = {
        return create(networkService: NetworkService<FilterDetailEndPoint>.self)
    }()
}
