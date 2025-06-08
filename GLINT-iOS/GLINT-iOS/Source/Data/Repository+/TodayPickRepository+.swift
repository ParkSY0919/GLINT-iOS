//
//  TodayPickRepository+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/8/25.
//

import Foundation

//TODO: Auth와 같도록 수정
extension TodayPickRepository {
    static func create<T: NetworkServiceInterface>(networkService: T.Type)
    -> TodayPickRepository where T.E == TodayPickEndPoint {
        let networkService = NetworkService<TodayPickEndPoint>()
        return .init(
            todayAuthor: {
                let endPoint = TodayPickEndPoint.todayAuthor
                return try await networkService.requestAsync(endPoint)
            },
            todayFilter: {
                let endPoint = TodayPickEndPoint.todayFilter
                return try await networkService.requestAsync(endPoint)
            },
            hotTrend: {
                let endPoint = TodayPickEndPoint.hotTrend
                return try await networkService.requestAsync(endPoint)
            }
        )
    }
}

extension TodayPickRepository {
    static let liveValue: TodayPickRepository = {
        return create(networkService: NetworkService<TodayPickEndPoint>.self)
    }()
}
