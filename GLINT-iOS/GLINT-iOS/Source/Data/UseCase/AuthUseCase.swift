//
//  AuthUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import SwiftUI

struct AuthUseCase {
    var checkEmailValidation: @Sendable (_ request: RequestEntity.CheckEmailValidation) async throws -> Bool
    var signUp: @Sendable (_ request: RequestEntity.SignUp) async throws -> ResponseEntity.SignIn
    var signIn: @Sendable (_ request: RequestEntity.SignIn) async throws -> ResponseEntity.SignIn
    var signInApple: @Sendable (_ request: RequestEntity.SignInApple) async throws -> ResponseEntity.SignIn
    var signInKakao: @Sendable (_ request: RequestEntity.SignInKakao) async throws -> ResponseEntity.SignIn
}

extension AuthUseCase {
    static let liveValue: AuthUseCase = {
        let repository: AuthRepository = .liveValue
        
        return AuthUseCase(
            checkEmailValidation: { entity in
                let request = entity.toRequest()
                try await repository.checkEmailValidation(request)
                print("이메일 유효성 검사 요청 성공 (UseCase)")
                return true
            },
            
            signUp: { entity in
                let request = entity.toRequest()
                let response = try await repository.signUp(request)
                
                print("회원가입 요청 성공 (UseCase)")
                
                return ResponseEntity.SignIn(
                    userID: response.userID,
                    email: response.email,
                    nick: response.nick,
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
            },
            
            signIn: { entity in
                let request = entity.toRequest()
                let response = try await repository.signIn(request)
                
                print("이메일 로그인 요청 성공 (UseCase)")
                
                return ResponseEntity.SignIn(
                    userID: response.userID,
                    email: response.email,
                    nick: response.nick,
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
            },
            
            signInApple: { entity in
                let request = entity.toAppleRequest()
                let response = try await repository.signInApple(request)
                
                print("애플 로그인 요청 성공 (UseCase)")
                
                return ResponseEntity.SignIn(
                    userID: response.userID,
                    email: response.email,
                    nick: response.nick,
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
            },
            
            signInKakao: { entity in
                let request = entity.toKakaoRequest()
                let response = try await repository.signInKakao(request)
                
                print("카카오 로그인 요청 성공 (UseCase)")
                
                return ResponseEntity.SignIn(
                    userID: response.userID,
                    email: response.email,
                    nick: response.nick,
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
            }
        )
    }()
    
}

// MARK: - Environment Key
struct AuthUseCaseKey: EnvironmentKey {
    static let defaultValue: AuthUseCase = .liveValue
}

extension EnvironmentValues {
    var authUseCase: AuthUseCase {
        get { self[AuthUseCaseKey.self] }
        set { self[AuthUseCaseKey.self] = newValue }
    }
}

extension AuthUseCase {
    static let mockValue: AuthUseCase = {
        let mockEntity = ResponseEntity.SignIn(
            userID: "mock_user_id",
            email: "mock@test.com",
            nick: "MockUser",
            accessToken: "mock_access_token",
            refreshToken: "mock_refresh_token"
        )
        
        return AuthUseCase(
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
                return ResponseEntity.SignIn(
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
                return ResponseEntity.SignIn(
                    userID: "mock_apple_id",
                    email: "apple@mock.com",
                    nick: result.nick,
                    accessToken: "mock_apple_access",
                    refreshToken: "mock_apple_refresh"
                )
            },
            
            signInKakao: { accessToken in
                print("Mock: 카카오 로그인")
                return ResponseEntity.SignIn(
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
