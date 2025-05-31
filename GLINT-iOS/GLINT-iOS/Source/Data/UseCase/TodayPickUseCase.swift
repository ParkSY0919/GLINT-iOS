//
//  TodayPickUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/29/25.
//

import SwiftUI

struct TodayPickUseCase {
    // 오늘의 작가 소개
    var todayAuthor: @Sendable () async throws -> ResponseEntity.TodayAuthor
    // 오늘의 필터 소개
    var todayFilter: @Sendable () async throws -> ResponseEntity.TodayFilter
}

extension TodayPickUseCase {
    static let liveValue: TodayPickUseCase = {
        let repository: TodayPickRepository = .liveValue
        
        return TodayPickUseCase(
            todayAuthor: {
                return try await repository.todayAuthor().toEntity()
            },
            todayFilter: {
                return try await repository.todayFilter().toEntity()
            }
        )
    }()
}

// MARK: - Environment Key
struct TodayPickUseCaseKey: EnvironmentKey {
    static let defaultValue: TodayPickUseCase = .liveValue
}

extension EnvironmentValues {
    var todayPickUseCase: TodayPickUseCase {
        get { self[TodayPickUseCaseKey.self] }
        set { self[TodayPickUseCaseKey.self] = newValue }
    }
}
