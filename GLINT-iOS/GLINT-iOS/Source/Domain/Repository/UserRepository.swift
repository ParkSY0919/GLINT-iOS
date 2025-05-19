//
//  UserRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/15/25.
//

import Foundation

struct UserRepository {
    var checkEmailValidation: (_ request: CheckEmailValidationRequest) async throws -> Void
    var signUp: (_ request: SignUpRequest) async throws -> SignUpResponse
}
