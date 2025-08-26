//
//  CommunityViewUseCase+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/26/25.
//

import Foundation

extension CommunityViewUseCase {
    static let liveValue: CommunityViewUseCase = {
        let repository: RecommendationRepository = .liveValue
        
        return CommunityViewUseCase(
            loadCommunityItems: {
                // 임시로 hotTrend 데이터를 사용 (실제로는 별도의 community API가 필요)
                let response = try await repository.hotTrend()
                return response.data.toEntities()
            }
        )
    }()
}