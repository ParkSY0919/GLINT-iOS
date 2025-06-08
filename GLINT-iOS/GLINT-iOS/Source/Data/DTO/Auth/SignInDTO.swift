//
//  SignIn.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import Foundation

// MARK: - Request
extension RequestDTO {
    struct SignIn: Codable {
        let email, password, deviceToken: String
    }
}

// MARK: - Response
extension ResponseDTO {
    struct SignIn: ResponseData {
        let userID, email, nick: String
        let accessToken, refreshToken: String
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case email, nick, accessToken, refreshToken
        }
    }
}

extension ResponseDTO.SignIn {
    func toEntity() -> ResponseEntity.SignIn {
        return ResponseEntity.SignIn(
            userID: userID,
            email: email,
            nick: nick,
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }
}

