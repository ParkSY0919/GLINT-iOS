//
//  SignInResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import Foundation

// MARK: - SignInResponse
struct SignInResponse: Codable {
    let userID, email, nick: String
    let accessToken, refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email, nick, accessToken, refreshToken
    }
}

extension SignInResponse {
    func toEntity() -> SignInEntity {
        return SignInEntity(
            userID: userID,
            email: email,
            nick: nick,
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }
}

struct SocialLoginResponse {
    let idToken: String
    let authorizationCode: String
    
    init(idToken: String, authorizationCode: String) {
        self.idToken = idToken
        self.authorizationCode = authorizationCode
    }
}
