//
//  AuthUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import Foundation

struct AuthUseCase {
    var checkEmailValidation: @Sendable (_ request: CheckEmailValidationRequestEntity) async throws -> Bool
    var signUp: @Sendable (_ request: SignUpRequestEntity) async throws -> SignInResponseEntity
    var signIn: @Sendable (_ request: SignInRequestEntity) async throws -> SignInResponseEntity
    var signInApple: @Sendable (_ request: SignInRequestAppleEntity) async throws -> SignInResponseEntity
    var signInKakao: @Sendable (_ request: SignInRequestKakaoEntity) async throws -> SignInResponseEntity
}
