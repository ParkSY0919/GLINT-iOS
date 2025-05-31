//
//  SignInForKakao.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import Foundation

// MARK: - Request
extension RequestDTO {
    struct SignInForKakao: Codable {
        let oauthToken, deviceToken: String
    }
}
