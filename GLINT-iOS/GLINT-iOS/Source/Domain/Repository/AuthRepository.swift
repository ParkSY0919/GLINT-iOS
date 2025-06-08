//
//  AuthRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/15/25.
//

import Foundation

struct AuthRepository {
    var checkEmailValidation: (_ request: EmailValidationEntity.Request) async throws -> Void
    var signUp: (_ request: SignUpEntity.Request) async throws -> SignUpEntity.Response
    var signIn: (_ request: SignInEntity.Request) async throws -> SignInEntity.Response
    var signInApple: (_ request: SignInAppleEntity.Request) async throws -> SignInEntity.Response
    var signInKakao: (_ request: SignInKakaoEntity.Request) async throws -> SignInEntity.Response
}
