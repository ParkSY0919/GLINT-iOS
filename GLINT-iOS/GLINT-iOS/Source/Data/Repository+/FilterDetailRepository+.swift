//
//  FilterDetailRepository+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/8/25.
//

import Foundation

extension FilterDetailRepository {
    static let liveValue: FilterDetailRepository = {
        let provider = NetworkService<FilterDetailEndPoint>()
        
        return FilterDetailRepository(
            filterDetail: { id in
                return try await provider.request(.filterDetail(filterId: id))
            }
        )
    }()
}
