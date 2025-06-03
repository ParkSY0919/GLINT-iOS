//
//  FilterDetailUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import SwiftUI

struct FilterDetailUseCase {
    var filterDetail: @Sendable (_ filterID: String) async throws -> FilterDetailEntity
}

extension FilterDetailUseCase {
    static let liveValue: FilterDetailUseCase = {
        let repo: FilterDetailRepository = .liveValue
        
        return FilterDetailUseCase (
            
            filterDetail: { filterID in
                let request = FilterDetailRequest(filter_id: filterID)
                return try await repo.filterDetail(request).toEntity()
                
            }
        )
    }()
    
}

struct FilterDetailUseCaseKey: EnvironmentKey {
    static let defaultValue: FilterDetailUseCase = .liveValue
}

extension EnvironmentValues {
    var filterDetailUseCase: FilterDetailUseCase {
        get { self[FilterDetailUseCaseKey.self] }
        set { self[FilterDetailUseCaseKey.self] = newValue }
    }
}
