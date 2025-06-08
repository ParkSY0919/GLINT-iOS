//
//  SignUpEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/24/25.
//

import Foundation

enum SignUpEntity {
    struct Request: RequestData {
        let email, password: String
        let deviceToken: String
    }
    
    struct Response: ResponseData {
        let userID: String
        let email: String
        let nick: String
        let accessToken: String
        let refreshToken: String
    }
}
