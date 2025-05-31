//
//  SignUpEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/24/25.
//

import Foundation

struct SignUpRequestEntity: Codable {
    let email, password: String
    let deviceToken: String
    
    func toRequest() -> RequestDTO.SignUp {
        return .init(
            email: email,
            password: password,
            nick: "psy",
            deviceToken: deviceToken
        )
    }
}

struct SignUpResponseEntity {
    let userID: String
    let email: String
    let nick: String
    let accessToken: String
    let refreshToken: String
}

extension SignUpResponseEntity {
    static let mock = SignUpResponseEntity(
        userID: "1234567890",
        email: "test@test.com",
        nick: "test",
        accessToken: "test",
        refreshToken: "test"
    )
}
