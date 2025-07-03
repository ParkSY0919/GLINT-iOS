//
//  MainViewUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/8/25.
//

import Foundation

struct MainViewUseCase {
    var todayAuthor: @Sendable () async throws -> TodayAuthorResponse
    var todayFilter: @Sendable () async throws -> TodayFilterResponse
    var hotTrend: @Sendable () async throws -> HotTrendResponse
    var loadMainViewState: @Sendable () async throws -> (FilterEntity, [FilterEntity], ProfileEntity, [FilterEntity])
}
