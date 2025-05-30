//
//  TodayPickRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/29/25.
//

import Foundation

struct TodayPickRepository {
    var todayAuthor: () async throws -> TodayArtistResponse
    var todayFilter: () async throws -> TodayFilterResponse
}

extension TodayPickRepository: NetworkServiceProvider {
    typealias E = TodayPickEndPoint
    
    static let liveValue: TodayPickRepository = {
        return TodayPickRepository(
            todayAuthor: {
                let endPoint = TodayPickEndPoint.todayAuthor
                return try await Self.requestAsync(endPoint)
            },
            todayFilter: {
                let endPoint = TodayPickEndPoint.todayFilter
                return try await Self.requestAsync(endPoint)
            }
        )
    }()
}
