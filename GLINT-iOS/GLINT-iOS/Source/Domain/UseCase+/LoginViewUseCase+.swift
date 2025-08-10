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
        let manager = LoginManager()
        
        func getDeviceTokenOrThrow() throws -> String {
            guard let token = keychain.getDeviceUUID() else {
                throw AuthError.noDeviceTokenFound
            }
            return token
        }
        
        return LoginViewUseCase(
            // email 유효성검사
            checkEmailValidation: { email in
                try Validator.validateEmail(email)
                try await repository.checkEmailValidation(email)
            },
            // 회원가입
            signUp: {email, password, nick in
                try Validator.validateEmail(email)
                try Validator.validatePassword(password)
                let deviceToken = try getDeviceTokenOrThrow()
                
                let request = SignUpRequest(
                    email: email,
                    password: password,
                    nick: nick,
                    deviceToken: deviceToken
                )
                
                let response = try await repository.signUp(request)
                GTLogger.i("회원가입 응답: \(response)")
                return response
            },
            // 로그인
            signIn: { email, password in
                try Validator.validateEmail(email)
                try Validator.validatePassword(password)
                let deviceToken = try getDeviceTokenOrThrow()
                
                let request = SignInRequest(
                    email: email,
                    password: password,
                    deviceToken: deviceToken
                )
                
                let response = try await repository.signIn(request)
                
                // 로그인 성공시 토큰과 사용자 정보 저장
                keychain.saveUserId(response.userID)
                keychain.saveNickname(response.nick)
                keychain.saveAccessToken(response.accessToken)
                keychain.saveRefreshToken(response.refreshToken)
                
                GTLogger.i("일반 로그인 성공 - 사용자 정보 저장: \(response.nick)")
                return response
            },
            // 로그인-apple
            signInApple: {
                let request = try await manager.appleLogin()
                let response = try await repository.signInApple(request)
                
                GTLogger.i("Apple 로그인 응답: \(response)")
                keychain.saveUserId(response.userID)
                keychain.saveNickname(response.nick)
                keychain.saveAccessToken(response.accessToken)
                keychain.saveRefreshToken(response.refreshToken)
                
                return response
            },
            // 로그인-kakao
            signInKakao: { entity in
                let request = entity
                let response = try await repository.signInKakao(request)
                
                // 카카오 로그인 성공시 토큰과 사용자 정보 저장
                keychain.saveUserId(response.userID)
                keychain.saveNickname(response.nick)
                keychain.saveAccessToken(response.accessToken)
                keychain.saveRefreshToken(response.refreshToken)
                
                GTLogger.i("Kakao 로그인 성공 - 사용자 정보 저장: \(response.nick)")
                return response
            },
            deviceTokenUpdate: { deviceToken in
                let response: Void = try await repository.deviceTokenUpdate(deviceToken)
                print("deviceTokenUpdate 결과: \(response)")
            }
        )
    }()
}
