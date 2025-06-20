//
//  MainViewUseCase+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/29/25.
//

import SwiftUI

extension MainViewUseCase {
    static let liveValue: MainViewUseCase = {
        let repository: RecommendationRepository = .liveValue
        
        return MainViewUseCase(
            todayAuthor: {
                return try await repository.todayAuthor()
            },
            todayFilter: {
                return try await repository.todayFilter()
            },
            hotTrend: {
                return try await repository.hotTrend()
            },
            loadMainViewState: {
                async let author = repository.todayAuthor()
                async let filter = repository.todayFilter()
                async let trend = repository.hotTrend()
                
                let (authorData, filterData, trendData) = try await (author, filter, trend)
                
                print("todayAuthor: \(authorData)\n")
                print("todayFilter: \(filterData)\n")
                print("hotTrend: \(trendData)\n")
                
                return MainViewState(
                    todayFilter: filterData,
                    todayArtist: authorData,
                    hotTrends: trendData,
                    isLoading: false,
                    errorMessage: nil,
                    hasLoadedOnce: true
                )
            }
        )
    }()
}

