//
//  SignUp.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/15/25.
//

import Foundation

enum SignUpDTO {
    struct Request: RequestData {
        let email, password, nick, deviceToken: String
    }
    
    struct Response: ResponseData {
        let userID, email, nick, accessToken: String
        let refreshToken: String
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case email, nick, accessToken, refreshToken
        }
    }
}

extension SignUpEntity.Request {
    func toDTO() -> SignUpDTO.Request {
        return .init(
            email: email,
            password: password,
            nick: "psy",
            deviceToken: deviceToken
        )
    }
}
