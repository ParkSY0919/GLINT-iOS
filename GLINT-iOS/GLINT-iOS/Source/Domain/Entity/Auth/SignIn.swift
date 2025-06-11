//
//  SignIn.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/24/25.
//

import Foundation

enum SignInEntity {
    struct Request: RequestData {
        let email, password, deviceToken: String
    }
    
    struct Response: ResponseData {
        let userID: String
        let email: String
        let nick: String
        let accessToken: String
        let refreshToken: String
    }
}
