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
//            todayAuthor: {
//                return try await repository.todayAuthor()
//            },
//            todayFilter: {
//                return try await repository.todayFilter()
//            },
//            hotTrend: {
//                return try await repository.hotTrend()
//            },
//            bannerList: {
//                return try await repository.bannerList()
//            },
            loadMainViewState: {
                async let filter = repository.todayFilter().toEntity()
                async let hotTrend = repository.hotTrend().data.toEntities()
                async let author = repository.todayAuthor()
                async let bannerList = repository.bannerList()
                
                let (
                    filterData,
                    hotTrendData,
                    authorDataProfile,
                    authorDataFilters,
                    bannerListData
                ) = try await (filter, hotTrend, author.author, author.filters, bannerList.data)
                
                return (filterData, hotTrendData, authorDataProfile.toEntity(), authorDataFilters.toEntities(), bannerListData)
            }
        )
    }()
}

