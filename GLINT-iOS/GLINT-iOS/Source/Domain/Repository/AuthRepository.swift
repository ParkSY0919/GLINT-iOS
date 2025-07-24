//
//  AuthRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/15/25.
//

import Foundation

struct AuthRepository {
    var checkEmailValidation: (_ email: String) async throws -> Void
    var signUp: (_ request: SignUpRequest) async throws -> SignUpResponse
    var signIn: (_ request: SignInRequest) async throws -> SignInResponse
    var signInApple: (_ request: SocialLoginEntity.Request) async throws -> SignInResponse
    var signInKakao: (_ request: SocialLoginEntity.Request) async throws -> SignInResponse
    var deviceTokenUpdate: (_ deviceToken: String) async throws -> Void
}
