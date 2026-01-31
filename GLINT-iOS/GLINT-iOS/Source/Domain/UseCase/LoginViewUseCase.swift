//
//  LoginViewUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/8/25.
//

import Foundation

struct LoginViewUseCase {
    var checkEmailValidation: @Sendable (_ email: String) async throws -> Void
    var signUp: @Sendable (_ email: String, _ password: String, _ nick: String) async throws -> AuthEntity
    var signIn: @Sendable (_ email: String, _ password: String) async throws -> AuthEntity
    var signInApple: @Sendable () async throws -> AuthEntity
    var signInKakao: @Sendable (_ request: SocialLoginEntity.Request) async throws -> AuthEntity
    var deviceTokenUpdate: (_ deviceToken: String) async throws -> Void
}
