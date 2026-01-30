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
            signUp: { email, password, nick in
                try Validator.validateEmail(email)
                try Validator.validatePassword(password)
                let deviceToken = try getDeviceTokenOrThrow()

                let entity = try await repository.signUp(email, password, nick, deviceToken)
                GTLogger.i("회원가입 응답: \(entity)")
                return entity
            },
            // 로그인
            signIn: { email, password in
                try Validator.validateEmail(email)
                try Validator.validatePassword(password)
                let deviceToken = try getDeviceTokenOrThrow()

                let entity = try await repository.signIn(email, password, deviceToken)

                // 로그인 성공시 토큰과 사용자 정보 저장
                keychain.saveUserId(entity.userID)
                keychain.saveNickname(entity.nick)
                keychain.saveAccessToken(entity.accessToken)
                keychain.saveRefreshToken(entity.refreshToken)

                GTLogger.i("일반 로그인 성공 - 사용자 정보 저장: \(entity.nick)")
                return entity
            },
            // 로그인-apple
            signInApple: {
                let request = try await manager.appleLogin()
                let entity = try await repository.signInApple(request)

                GTLogger.i("Apple 로그인 응답: \(entity)")
                keychain.saveUserId(entity.userID)
                keychain.saveNickname(entity.nick)
                keychain.saveAccessToken(entity.accessToken)
                keychain.saveRefreshToken(entity.refreshToken)

                return entity
            },
            // 로그인-kakao
            signInKakao: { request in
                let entity = try await repository.signInKakao(request)

                // 카카오 로그인 성공시 토큰과 사용자 정보 저장
                keychain.saveUserId(entity.userID)
                keychain.saveNickname(entity.nick)
                keychain.saveAccessToken(entity.accessToken)
                keychain.saveRefreshToken(entity.refreshToken)

                GTLogger.i("Kakao 로그인 성공 - 사용자 정보 저장: \(entity.nick)")
                return entity
            },
            deviceTokenUpdate: { deviceToken in
                let response: Void = try await repository.deviceTokenUpdate(deviceToken)
                print("deviceTokenUpdate 결과: \(response)")
            }
        )
    }()
}
