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
            checkEmailValidation: { request in
                let request = request.toDTO()
                try await provider.requestAsyncVoid(.checkEmailValidation(email: request.email))
            },
            signUp: { request in
                let request = request.toDTO()
                return try await provider.requestAsync(.signUp(request))
            },
            signIn: { request in
                let request = request.toDTO()
                return try await provider.requestAsync(.signIn(request))
            },
            signInApple: { request in
                let request = request.toDTO()
                let response: SignInDTO.Response = try await provider.requestAsync(.signInForApple(request))
                return response.toEntity()
            },
            signInKakao: { request in
                let request = request.toDTO()
                return try await provider.requestAsync(.signInForKakao(request))
            }
        )
    }()
}
