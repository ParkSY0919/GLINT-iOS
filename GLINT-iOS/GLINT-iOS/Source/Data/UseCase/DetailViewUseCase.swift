//
//  DetailViewUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import SwiftUI

struct DetailViewUseCase {
    var filterDetail: @Sendable (_ filterID: String) async throws -> FilterDetailEntity
}

extension DetailViewUseCase {
    static let liveValue: DetailViewUseCase = {
        let repo: FilterDetailRepository = .liveValue
        
        return DetailViewUseCase (
            filterDetail: { filterID in
                return try await repo.filterDetail(filterID).toEntity()
            }
        )
    }()
    
}

struct DetailViewUseCaseKey: EnvironmentKey {
    static let defaultValue: DetailViewUseCase = .liveValue
}

extension EnvironmentValues {
    var DetailViewUseCase: DetailViewUseCase {
        get { self[DetailViewUseCaseKey.self] }
        set { self[DetailViewUseCaseKey.self] = newValue }
    }
}
