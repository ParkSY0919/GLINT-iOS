//
//  UserUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import Foundation

struct UserUseCase {
    var checkEmailValidation: (_ request: CheckEmailValidationRequest) async throws -> Void
    var signUp: (_ request: SignUpRequest) async throws -> SignUpResponse
}
