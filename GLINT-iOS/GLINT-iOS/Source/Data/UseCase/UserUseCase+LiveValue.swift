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
        let keychain = KeychainProvider.shared
        
        return UserUseCase(
            checkEmailValidation: { request in
                try await repository.checkEmailValidation(request)
                print("이메일 유효성 검사 요청 성공 (UseCase)")
                return true
            },
            
            signUp: { request in
                let response = try await repository.signUp(request)
                
                print("회원가입 요청 성공 (UseCase)")
                
                return SignInResponseEntity(
                    userID: response.userID,
                    email: response.email,
                    nick: response.nick,
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
            },
            
            signIn: { request in
                let response = try await repository.signIn(request)
                
                print("이메일 로그인 요청 성공 (UseCase)")
                
                return SignInResponseEntity(
                    userID: response.userID,
                    email: response.email,
                    nick: response.nick,
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
            },
            
            signInApple: { request in
                let response = try await repository.signInApple(request)
                
                print("애플 로그인 요청 성공 (UseCase)")
                
                return SignInResponseEntity(
                    userID: response.userID,
                    email: response.email,
                    nick: response.nick,
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
            },
            
            signInKakao: { request in
                let response = try await repository.signInKakao(request)
                
                print("카카오 로그인 요청 성공 (UseCase)")
                
                return SignInResponseEntity(
                    userID: response.userID,
                    email: response.email,
                    nick: response.nick,
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
            }
        )
    }()
    
    static let mockValue: UserUseCase = {
        let mockEntity = SignInResponseEntity(
            userID: "mock_user_id",
            email: "mock@test.com",
            nick: "MockUser",
            accessToken: "mock_access_token",
            refreshToken: "mock_refresh_token"
        )
        
        return UserUseCase(
            checkEmailValidation: { request in
                print("Mock: 이메일 유효성 검사 - \(request.email)")
                // 특정 이메일에서 실패 테스트
                if request.email == "invalid@test.com" {
                    throw URLError(.badURL)
                }
                return true
            },
            
            signUp: { request in
                print("Mock: 회원가입 - \(request.email)")
                return SignInResponseEntity(
                    userID: "mock_signup_id",
                    email: request.email,
                    nick: "nickname",
                    accessToken: "mock_signup_access",
                    refreshToken: "mock_signup_refresh"
                )
            },
            
            signIn: { request in
                print("Mock: 이메일 로그인 - \(request.email)")
                return mockEntity
            },
            
            signInApple: { result in
                print("Mock: 애플 로그인 - \(result.nick)")
                return SignInResponseEntity(
                    userID: "mock_apple_id",
                    email: "apple@mock.com",
                    nick: result.nick,
                    accessToken: "mock_apple_access",
                    refreshToken: "mock_apple_refresh"
                )
            },
            
            signInKakao: { accessToken in
                print("Mock: 카카오 로그인")
                return SignInResponseEntity(
                    userID: "mock_kakao_id",
                    email: "kakao@mock.com",
                    nick: "Kakao User",
                    accessToken: "mock_kakao_access",
                    refreshToken: "mock_kakao_refresh"
                )
            }
        )
    }()
}

// MARK: - Environment Key
struct UserUseCaseKey: EnvironmentKey {
    static let defaultValue: UserUseCase = .liveValue
}

extension EnvironmentValues {
    var userUseCase: UserUseCase {
        get { self[UserUseCaseKey.self] }
        set { self[UserUseCaseKey.self] = newValue }
    }
}
