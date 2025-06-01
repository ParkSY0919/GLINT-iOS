//
//  RefreshToken.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/27/25.
//

import Foundation

// MARK: - Request
extension RequestDTO {
    struct RefreshToken: Codable {
        let refreshToken: String
    }
}

// MARK: - Response
extension ResponseDTO {
    struct RefreshToken: Codable {
        let accessToken: String
        let refreshToken: String
    }
}
