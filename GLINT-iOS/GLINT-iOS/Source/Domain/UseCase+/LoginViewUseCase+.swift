//
//  LoginViewUseCase+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//


/*
 # 왜 데이터레이어가 아닌 도메인레이어에 usecase의 구현부를 옮겼는가?
 
 - usecase에서 사용하는 모든 것들은 도메인에 있는 내용 혹은 코어에 있는 내용이기에 데이터 레이어에 존재할 이유가 없다.
    즉, 모든 의존성은 안 쪽으로 향한다는 클린아키텍처 규정을 위반하기에
 */

import Foundation

extension LoginViewUseCase {
    static let liveValue: LoginViewUseCase = {
        let repository: AuthRepository = .value
        let keychain: KeychainManager = .shared
        
        return LoginViewUseCase(
            // email 유효성검사
            checkEmailValidation: { email in
                guard Validator.isValidEmailFormat(email) else {
                    throw AuthError.invalidEmailFormat
                }
                try await repository.checkEmailValidation(email)
            },
            // 회원가입
            signUp: {email, password, nick in
                guard Validator.isValidEmailFormat(email) else {
                    throw AuthError.invalidEmailFormat
                }
                
                guard Validator.isValidPasswordFormat(password) else {
                    throw AuthError.invalidPasswordFormat
                }
                
                guard let deviceToken = keychain.getDeviceUUID() else {
                    throw AuthError.noDeviceTokenFound
                }
                
                let request = SignUpRequest(
                    email: email,
                    password: password,
                    nick: nick,
                    deviceToken: deviceToken
                )
                
                let response = try await repository.signUp(request)
                return response
            },
            // 로그인
            signIn: { entity in
                let request = entity
                let response = try await repository.signIn(request)
                return response
            },
            // 로그인-apple
            signInApple: { entity in
                let request = entity
                let response = try await repository.signInApple(request)
                
                GTLogger.i("Apple 로그인 응답: \(response)")
                keychain.saveAccessToken(response.accessToken)
                keychain.saveRefreshToken(response.refreshToken)
                return response
            },
            // 로그인-kakao
            signInKakao: { entity in
                let request = entity
                let response = try await repository.signInKakao(request)
                return response
            }
        )
    }()
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case noTokenFound
    case tokenRefreshFailed
    case tokenSaveFailed
    case invalidEmailFormat
    case invalidPasswordFormat
    case noDeviceTokenFound
    
    var errorDescription: String? {
        switch self {
        case .noTokenFound: return "저장된 토큰이 없습니다."
        case .tokenRefreshFailed: return "토큰 갱신에 실패했습니다."
        case .tokenSaveFailed: return "토큰 저장에 실패했습니다."
        case .invalidEmailFormat: return "올바른 이메일 형식이 아닙니다."
        case .invalidPasswordFormat: return "올바른 비밀번호 형식이 아닙니다."
        case .noDeviceTokenFound: return "디바이스 토큰이 없습니다."
        }
    }
}


