//
//  RefreshTokenResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/19/25.
//

import Foundation

struct RefreshTokenResponse: ResponseData {
    let accessToken: String
    let refreshToken: String
}
