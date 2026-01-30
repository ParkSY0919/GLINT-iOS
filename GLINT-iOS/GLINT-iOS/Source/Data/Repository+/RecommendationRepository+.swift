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
                let response: TodayAuthorResponse = try await provider.request(.todayAuthor)
                return response.toEntity()
            },
            // 오늘의 필터
            todayFilter: {
                let response: TodayFilterResponse = try await provider.request(.todayFilter)
                return response.toEntity()
            },
            // 핫 트렌드
            hotTrend: {
                let response: HotTrendResponse = try await provider.request(.hotTrend)
                return response.toEntity()
            },
            bannerList: {
                let response: BannerListResponse = try await provider.request(.banner)
                return response.toEntity()
            }
        )
    }()
}
