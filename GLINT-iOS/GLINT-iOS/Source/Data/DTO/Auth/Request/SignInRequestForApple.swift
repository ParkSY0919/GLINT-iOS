//
//  SignInRequestForApple.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import Foundation

// MARK: - SignInRequestForApple
struct SignInRequestForApple: Codable {
    let idToken, deviceToken, nick: String
}
