//
//  MainViewUseCase+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/29/25.
//

import Foundation

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
                async let filter = repository.todayFilter().toEntity()
                async let hotTrend = repository.hotTrend().data.toEntities()
                async let author = repository.todayAuthor()
                
                let (
                    filterData,
                    hotTrendData,
                    authorDataProfile,
                    authorDataFilters
                ) = try await (filter, hotTrend, author.author, author.filters)
                
                return (filterData, hotTrendData, authorDataProfile.toEntity(), authorDataFilters.toEntities())
            }
        )
    }()
}

