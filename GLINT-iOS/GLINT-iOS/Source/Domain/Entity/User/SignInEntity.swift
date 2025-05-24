//
//  SignInEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/24/25.
//

import Foundation

struct SignInEntity {
    let userID: String
    let email: String
    let nick: String
    let accessToken: String
    let refreshToken: String
}

extension SignInEntity {
    static let mock = SignInEntity(
        userID: "psyyy",
        email: "test@test.com",
        nick: "test",
        accessToken: "test",
        refreshToken: "test"
    )
}
