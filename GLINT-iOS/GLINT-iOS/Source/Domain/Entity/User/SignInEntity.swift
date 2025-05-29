//
//  SignInEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/24/25.
//

import Foundation

struct SignInRequestAppleEntity {
    let idToken, deviceToken, nick: String
    
    func toAppleRequest() -> SignInRequestForApple {
        return .init(
            idToken: idToken,
            deviceToken: deviceToken,
            nick: nick
        )
    }
}

struct SignInRequestKakaoEntity {
    let oauthToken, deviceToken: String
    
    func toKakaoRequest() -> SignInRequestForKakao {
        return .init(oauthToken: oauthToken, deviceToken: deviceToken)
    }
}

struct SignInRequestEntity: Codable {
    let email, password, deviceToken: String
    
    func toRequest() -> SignInRequest {
        return .init(
            email: email,
            password: password,
            deviceToken: deviceToken
        )
    }
}

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
