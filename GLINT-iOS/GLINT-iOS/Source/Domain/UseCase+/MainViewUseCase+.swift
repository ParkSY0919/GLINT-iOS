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
            loadMainViewState: {
                async let filter = repository.todayFilter()
                async let hotTrend = repository.hotTrend()
                async let author = repository.todayAuthor()
                async let bannerList = repository.bannerList()

                let (
                    filterData,
                    hotTrendData,
                    authorData,
                    bannerListData
                ) = try await (filter, hotTrend, author, bannerList)

                return (filterData, hotTrendData.filters, authorData.author, authorData.filters, bannerListData.banners)
            }
        )
    }()
}

