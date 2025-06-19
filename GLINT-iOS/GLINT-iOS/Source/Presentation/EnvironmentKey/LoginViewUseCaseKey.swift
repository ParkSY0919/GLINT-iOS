//
//  LoginViewUseCaseKey.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/19/25.
//

import SwiftUI

// MARK: - Environment Key
struct LoginViewUseCaseKey: EnvironmentKey {
    static let defaultValue: LoginViewUseCase = .liveValue
}

extension EnvironmentValues {
    var loginViewUseCase: LoginViewUseCase {
        get { self[LoginViewUseCaseKey.self] }
        set { self[LoginViewUseCaseKey.self] = newValue }
    }
}
