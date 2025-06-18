//
//  LoginViewUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/8/25.
//

import Foundation

struct LoginViewUseCase {
    var checkEmailValidation: @Sendable (_ request: EmailValidationEntity.Request) async throws -> Void
    var signUp: @Sendable (_ request: SignUpEntity.Request) async throws -> SignUpEntity.Response
    var signIn: @Sendable (_ request: SignInEntity.Request) async throws -> SignInEntity.Response
    var signInApple: @Sendable (_ request: SocialLoginEntity.Request) async throws -> SignInEntity.Response
    var signInKakao: @Sendable (_ request: SocialLoginEntity.Request) async throws -> SignInEntity.Response
}
