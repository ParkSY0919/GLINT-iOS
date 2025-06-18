//
//  SocialLoginEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/31/25.
//

import Foundation

enum SocialLoginEntity {
    enum Provider {
        case apple(idToken: String, nick: String)
        case kakao(oauthToken: String)
    }
    
    struct Request {
        let provider: Provider
        let deviceToken: String
    }
}
