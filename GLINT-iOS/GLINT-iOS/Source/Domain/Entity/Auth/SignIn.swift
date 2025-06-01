//
//  SignIn.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/24/25.
//

import Foundation

extension RequestEntity {
    struct SignIn: Codable {
        let email, password, deviceToken: String
        
        func toRequest() -> RequestDTO.SignIn {
            return .init(
                email: email,
                password: password,
                deviceToken: deviceToken
            )
        }
    }
}

extension ResponseEntity {
    struct SignIn {
        let userID: String
        let email: String
        let nick: String
        let accessToken: String
        let refreshToken: String
    }
}

extension ResponseEntity.SignIn {
    static let mock = ResponseEntity.SignIn(
        userID: "psyyy",
        email: "test@test.com",
        nick: "test",
        accessToken: "test",
        refreshToken: "test"
    )
}
