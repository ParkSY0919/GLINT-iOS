//
//  UserUseCase+LiveValue.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import SwiftUI

extension UserUseCase {
    static let liveValue: UserUseCase = {
        let repository: UserRepository = .liveValue
        
        return UserUseCase(
            checkEmailValidation: { request in
                try await repository.checkEmailValidation(request)
                print("이메일 유효성 검사 요청 성공 (UseCase)")
            },
            signUp: { request in
                let response = try await repository.signUp(request)
                print("회원가입 요청 성공 (UseCase)")
                return response
            }
        )
    }()
    
    static let mockValue: UserUseCase = {
        return UserUseCase(
            checkEmailValidation: { request in
                // Mock 구현 - 테스트용
                print("Mock: 이메일 유효성 검사 - \(request.email)")
                // 특정 조건에서 에러 발생시키기 (테스트용)
                if request.email == "invalid@test.com" {
                    throw URLError(.badURL)
                }
            },
            signUp: { request in
                // Mock 구현 - 테스트용
                print("Mock: 회원가입 - \(request.email)")
                return SignUpResponse(
                    userID: "mockUp",
                    email: "mockUp",
                    nick: "mockUp",
                    accessToken: "mockUp",
                    refreshToken: "mockUp"
                )
            }
        )
    }()
}

struct UserUseCaseKey: EnvironmentKey {
    static let defaultValue: UserUseCase = .liveValue
}

extension EnvironmentValues {
    var userUseCase: UserUseCase {
        get { self[UserUseCaseKey.self] }
        set { self[UserUseCaseKey.self] = newValue }
    }
}
