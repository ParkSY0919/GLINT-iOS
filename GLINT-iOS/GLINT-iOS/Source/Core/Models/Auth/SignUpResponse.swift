//
//  SignUpResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/19/25.
//

import Foundation

struct SignUpResponse: ResponseData {
    let userID: String
    let email: String
    let nick: String
    let accessToken: String
    let refreshToken: String
}
