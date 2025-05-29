//
//  UserUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import Foundation

struct UserUseCase {
    var checkEmailValidation: (_ request: CheckEmailValidationRequest) async throws -> Bool
    var signUp: (_ request: SignUpRequest) async throws -> SignInResponseEntity
    var signIn: (_ request: SignInRequest) async throws -> SignInResponseEntity
    var signInApple: (_ request: SignInRequestForApple) async throws -> SignInResponseEntity
    var signInKakao: (_ request: SignInRequestForKakao) async throws -> SignInResponseEntity
}
