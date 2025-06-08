//
//  MainViewUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/8/25.
//

import Foundation

struct MainViewUseCase {
    var todayAuthor: @Sendable () async throws -> ResponseEntity.TodayAuthor // 오늘의 작가 소개
    var todayFilter: @Sendable () async throws -> ResponseEntity.TodayFilter // 오늘의 필터 소개
    var hotTrend: @Sendable () async throws -> ResponseEntity.HotTrend
}
