//
//  AuthRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/15/25.
//

import Foundation

struct AuthRepository {
    var checkEmailValidation: (_ email: String) async throws -> Void
    var signUp: (_ request: RequestDTO.SignUp) async throws -> ResponseDTO.SignUp
    var signIn: (_ request: RequestDTO.SignIn) async throws -> ResponseDTO.SignIn
    var signInApple: (_ request: RequestDTO.SignInForApple) async throws -> ResponseDTO.SignIn
    var signInKakao: (_ request: RequestDTO.SignInForKakao) async throws -> ResponseDTO.SignIn
}

extension AuthRepository {
    static func create<T: NetworkServiceInterface>(networkService: T.Type)
    -> AuthRepository where T.E == AuthEndPoint {
        return AuthRepository(
            checkEmailValidation: { email in
                let endPoint = T.E.checkEmailValidation(email: email)
                try await networkService.requestNonToken(endPoint)
            },
            signUp: { request in
                let endPoint = T.E.signUp(request)
                return try await networkService.requestNonToken(endPoint)
            },
            signIn: { request in
                let endPoint = T.E.signIn(request)
                return try await networkService.requestNonToken(endPoint)
            },
            signInApple: { request in
                let endPoint = T.E.signInForApple(request)
                return try await networkService.requestNonToken(endPoint)
            },
            signInKakao: { request in
                let endPoint = T.E.signInForKakao(request)
                return try await networkService.requestNonToken(endPoint)
            }
        )
    }
}

// Application Layer - Composition Root (의존성 조립)
extension AuthRepository {
    static let liveValue: AuthRepository = {
        return create(networkService: NetworkService<AuthEndPoint>.self)
    }()
    
//    static let mockValue: AuthRepository = {
//        return create(networkService: MockNetworkService<AuthEndPoint>.self)
//    }()
}
