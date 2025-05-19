//
//  SignUpResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import Foundation

struct SignUpResponse: Decodable {
    let userID, email, nick, accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email, nick, accessToken, refreshToken
    }
}
