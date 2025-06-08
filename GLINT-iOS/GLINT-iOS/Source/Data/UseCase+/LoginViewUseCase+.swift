//
//  LoginViewUseCase+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import SwiftUI

extension LoginViewUseCase {
    static let liveValue: LoginViewUseCase = {
        let repository: AuthRepository = .value
        
        return LoginViewUseCase(
            checkEmailValidation: { email in
                try await repository.checkEmailValidation(email)
            },
            signUp: { entity in
                let request = entity
                let response = try await repository.signUp(request)
                return response
            },
            signIn: { entity in
                let request = entity
                let response = try await repository.signIn(request)
                return response
            },
            signInApple: { entity in
                let request = entity
                let response = try await repository.signInApple(request)
                return response
            },
            signInKakao: { entity in
                let request = entity
                let response = try await repository.signInKakao(request)
                return response
            }
        )
    }()
    
}

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
