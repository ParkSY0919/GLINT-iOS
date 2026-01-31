//
//  RecommendationRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/29/25.
//

import Foundation

struct RecommendationRepository {
    var todayAuthor: () async throws -> TodayAuthorEntity
    var todayFilter: () async throws -> FilterEntity
    var hotTrend: () async throws -> HotTrendEntity
    var bannerList: () async throws -> BannerListEntity
}
