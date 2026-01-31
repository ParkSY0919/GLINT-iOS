//
//  AuthRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/15/25.
//

import Foundation

struct AuthRepository {
    var checkEmailValidation: (_ email: String) async throws -> Void
    var signUp: (_ email: String, _ password: String, _ nick: String, _ deviceToken: String) async throws -> AuthEntity
    var signIn: (_ email: String, _ password: String, _ deviceToken: String) async throws -> AuthEntity
    var signInApple: (_ request: SocialLoginEntity.Request) async throws -> AuthEntity
    var signInKakao: (_ request: SocialLoginEntity.Request) async throws -> AuthEntity
    var deviceTokenUpdate: (_ deviceToken: String) async throws -> Void
}
