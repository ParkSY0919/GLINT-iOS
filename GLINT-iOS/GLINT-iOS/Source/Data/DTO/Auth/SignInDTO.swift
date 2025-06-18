//
//  SignIn.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import Foundation

enum SignInDTO {
    struct Request: RequestData {
        let email, password, deviceToken: String
    }
    
    struct Response: ResponseData {
        let userID, email, nick: String
        let accessToken, refreshToken: String
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case email, nick, accessToken, refreshToken
        }
        
        func toEntity() -> SignInEntity.Response {
            return .init(
                userID: userID,
                email: email,
                nick: nick,
                accessToken: accessToken,
                refreshToken: refreshToken
            )
        }
    }
}

extension SignInEntity.Request {
    func toDTO() -> SignInDTO.Request {
        return .init(
            email: email,
            password: password,
            deviceToken: deviceToken
        )
    }
}
