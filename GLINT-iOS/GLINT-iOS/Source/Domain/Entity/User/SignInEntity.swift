//
//  SignInEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/24/25.
//

import Foundation

struct SignInResponseEntity {
    let userID: String
    let email: String
    let nick: String
    let accessToken: String
    let refreshToken: String
}

extension SignInResponseEntity {
    static let mock = SignInResponseEntity(
        userID: "psyyy",
        email: "test@test.com",
        nick: "test",
        accessToken: "test",
        refreshToken: "test"
    )
}
