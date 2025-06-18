//
//  AuthRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/15/25.
//

import Foundation

struct AuthRepository {
    var checkEmailValidation: (_ email: String) async throws -> Void
    var signUp: (_ request: SignUpEntity.Request) async throws -> SignUpEntity.Response
    var signIn: (_ request: SignInEntity.Request) async throws -> SignInEntity.Response
    var signInApple: (_ request: SocialLoginEntity.Request) async throws -> SignInEntity.Response
    var signInKakao: (_ request: SocialLoginEntity.Request) async throws -> SignInEntity.Response
}
