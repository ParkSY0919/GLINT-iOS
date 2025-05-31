//
//  SignUp.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/15/25.
//

import Foundation

// MARK: - Request
extension RequestDTO {
    struct SignUp: Codable {
        let email, password, nick, deviceToken: String
    }
}

// MARK: - Response
extension ResponseDTO {
    struct SignUp: Decodable {
        let userID, email, nick, accessToken: String
        let refreshToken: String
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case email, nick, accessToken, refreshToken
        }
    }
}
