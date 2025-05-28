//
//  RefreshTokenResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/27/25.
//

import Foundation

// MARK: - RefreshTokenResponse
struct RefreshTokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}
