//
//  RecommendationRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/29/25.
//

import Foundation

struct RecommendationRepository {
    var todayAuthor: () async throws -> TodayAuthorResponse
    var todayFilter: () async throws -> TodayFilterResponse
    var hotTrend: () async throws -> HotTrendResponse
}
