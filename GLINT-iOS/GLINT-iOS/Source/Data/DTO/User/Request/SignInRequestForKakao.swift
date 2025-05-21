//
//  SignInRequestForKakao.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import Foundation

// MARK: - SignInRequestForKakao
struct SignInRequestForKakao: Codable {
    let oauthToken, deviceToken: String
}
