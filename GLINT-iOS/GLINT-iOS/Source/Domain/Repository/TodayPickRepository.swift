//
//  TodayPickRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/29/25.
//

import Foundation

struct TodayPickRepository {
    var todayAuthor: () async throws -> ResponseDTO.TodayAuthor
    var todayFilter: () async throws -> ResponseDTO.TodayFilter
    var hotTrend: () async throws -> ResponseDTO.HotTrend
}
