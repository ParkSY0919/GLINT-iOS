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
            signUp: { request in
                return try await provider.request(.signUp(request))
            },
            signIn: { request in
                return try await provider.request(.signIn(request))
            },
            signInApple: { request in
                let request = request.toAppleRequest()
                let response: SignInResponse = try await provider.request(.signInForApple(request))
                return response
            },
            signInKakao: { request in
                let request = request.toKakaoRequest()
                let response: SignInResponse = try await provider.request(.signInForKakao(request))
                return response
            }
        )
    }()
}
