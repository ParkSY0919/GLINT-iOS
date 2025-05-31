//
//  SocialLogin.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/31/25.
//

import Foundation

// MARK: - Request
extension ResponseDTO {
    struct SocialLogin {
        let idToken: String
        let authorizationCode: String
        let nick: String
        
        init(idToken: String, authorizationCode: String, nick: String) {
            self.idToken = idToken
            self.authorizationCode = authorizationCode
            self.nick = nick
        }
    }
}
