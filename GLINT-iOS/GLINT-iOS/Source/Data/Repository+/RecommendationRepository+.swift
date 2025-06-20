//
//  RecommendationRepository+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/8/25.
//

import Foundation

extension RecommendationRepository {
    static let liveValue: RecommendationRepository = {
        let provider = NetworkService<RecommendationEndPoint>()
        
        return RecommendationRepository(
            // 오늘의 작가
            todayAuthor: {
                return try await provider.requestAsync(.todayAuthor)
            },
            // 오늘의 필터
            todayFilter: {
                return try await provider.requestAsync(.todayFilter)
            },
            // 핫 트렌드
            hotTrend: {
                return try await provider.requestAsync(.hotTrend)
            }
        )
    }()
}
