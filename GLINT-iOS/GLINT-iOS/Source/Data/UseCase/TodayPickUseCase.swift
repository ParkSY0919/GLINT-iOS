//
//  TodayPickUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/29/25.
//

import Foundation

struct TodayPickUseCase {
    // 오늘의 작가 소개
    var todayAuthor: @Sendable () async throws -> TodayArtistResponseEntity
    // 오늘의 필터 소개
    var todayFilter: @Sendable () async throws -> TodayFilterResponseEntity
}
