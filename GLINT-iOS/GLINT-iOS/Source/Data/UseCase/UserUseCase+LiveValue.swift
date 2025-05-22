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
            },
            signIn: { request in
                let response = try await repository.signIn(request)
                print("이메일 로그인 요청 성공 (UseCase)")
                return response
            },
            signInApple: { request in
                let response = try await repository.signInApple(request)
                print("애플 로그인 요청 성공 (UseCase)")
                return response
            },
            signInKakao: { request in
                let response = try await repository.signInKakao(request)
                print("카카오 로그인 요청 성공 (UseCase)")
                return response
            }
        )
    }()
    
    //TODO: 이거 테스트 코드에서 바로 불러와쓰자.
    static let mockValue: UserUseCase = {
        let signInResponse = SignInResponse(
            userID: "mock",
            email: "mock",
            nick: "mock",
            accessToken: "mock",
            refreshToken: "mock"
        )
        
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
            },
            signIn: { request in
                print("Mock: 이메일 로그인")
                return signInResponse
            },
            signInApple: { request in
                print("Mock: 카카오 로그인")
                return signInResponse
            },
            signInKakao: { request in
                print("Mock: 애플 로그인")
                return signInResponse
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
