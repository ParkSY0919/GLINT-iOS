//
//  MainViewUseCaseKey.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/19/25.
//

import SwiftUI

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
