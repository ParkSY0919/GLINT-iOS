//
//  AuthRepository+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/8/25.
//

import Foundation

extension AuthRepository {
    static let value: AuthRepository = {
        let provider = NetworkService<AuthEndPoint>()

        return AuthRepository(
            checkEmailValidation: { email in
                try await provider.requestVoid(.checkEmailValidation(email: email))
            },
            signUp: { email, password, nick, deviceToken in
                let request = SignUpRequest(email: email, password: password, nick: nick, deviceToken: deviceToken)
                let response: SignUpResponse = try await provider.request(.signUp(request))
                return response.toEntity()
            },
            signIn: { email, password, deviceToken in
                let request = SignInRequest(email: email, password: password, deviceToken: deviceToken)
                let response: SignInResponse = try await provider.request(.signIn(request))
                return response.toEntity()
            },
            signInApple: { request in
                let appleRequest = request.toAppleRequest()
                let response: SignInResponse = try await provider.request(.signInForApple(appleRequest))
                return response.toEntity()
            },
            signInKakao: { request in
                let kakaoRequest = request.toKakaoRequest()
                let response: SignInResponse = try await provider.request(.signInForKakao(kakaoRequest))
                return response.toEntity()
            },
            deviceTokenUpdate: { deviceToken in
                return try await provider.requestVoid(.deviceToken(token: deviceToken))
            }
        )
    }()
}
