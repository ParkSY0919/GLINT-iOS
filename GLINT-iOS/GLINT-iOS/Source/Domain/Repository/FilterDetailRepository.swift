//
//  FilterDetailRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import Foundation

struct FilterDetailRepository {
    var filterDetail: (_ filterId: String) async throws -> FilterDetailEntity
}

//TODO: Repo가 DTO를 알고있음 -> 추후 수정.
extension FilterDetailRepository {
    static func create<T: NetworkServiceInterface>(networkService: T.Type)
    -> FilterDetailRepository where T.E == FilterDetailEndPoint {
        let networkService = NetworkService<FilterDetailEndPoint>()
        
        return .init(filterDetail: {
            let endpoint = FilterDetailEndPoint.filterDetail(filterId: $0)
            let responseDTO: FilterDetailResponse = try await networkService.requestAsync(endpoint)
            return responseDTO.toEntity()
        })
    }
}

extension FilterDetailRepository {
    static let liveValue: FilterDetailRepository = {
        return create(networkService: NetworkService<FilterDetailEndPoint>.self)
    }()
}
