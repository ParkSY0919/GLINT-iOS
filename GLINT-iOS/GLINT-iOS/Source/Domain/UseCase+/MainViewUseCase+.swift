//
//  MainViewUseCase+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/29/25.
//

import SwiftUI

//TODO: LoginView와 같도록 수정
extension MainViewUseCase {
    static let liveValue: MainViewUseCase = {
        let repository: TodayPickRepository = .liveValue
        
        return MainViewUseCase(
            todayAuthor: {
                return try await repository.todayAuthor().toEntity()
            },
            todayFilter: {
                return try await repository.todayFilter().toEntity()
            },
            hotTrend: {
                return try await repository.hotTrend().toEntity()
            }
        )
    }()
}

// MARK: - Environment Key
struct MainViewUseCaseKey: EnvironmentKey {
    static let defaultValue: MainViewUseCase = .liveValue
}

extension EnvironmentValues {
    var mainViewUseCase: MainViewUseCase {
        get { self[MainViewUseCaseKey.self] }
        set { self[MainViewUseCaseKey.self] = newValue }
    }
}
