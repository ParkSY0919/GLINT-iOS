//
//  UserUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import Foundation

struct UserUseCase {
    var checkEmailValidation: (_ request: CheckEmailValidationRequestEntity) async throws -> Bool
    var signUp: (_ request: SignUpRequestEntity) async throws -> SignInResponseEntity
    var signIn: (_ request: SignInRequestEntity) async throws -> SignInResponseEntity
    var signInApple: (_ request: SignInRequestAppleEntity) async throws -> SignInResponseEntity
    var signInKakao: (_ request: SignInRequestKakaoEntity) async throws -> SignInResponseEntity
}
