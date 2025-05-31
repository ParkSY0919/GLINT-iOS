//
//  SignUp.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/24/25.
//

import Foundation

extension RequestEntity {
    struct SignUp: Codable {
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
}

extension ResponseEntity {
    struct SignUp {
        let userID: String
        let email: String
        let nick: String
        let accessToken: String
        let refreshToken: String
    }
}

extension ResponseEntity.SignUp {
    static let mock = ResponseEntity.SignUp(
        userID: "1234567890",
        email: "test@test.com",
        nick: "test",
        accessToken: "test",
        refreshToken: "test"
    )
}
