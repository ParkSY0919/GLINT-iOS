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
        
        func toAppleRequest() -> SignInAppleRequest {
            guard case .apple(let idToken, let nick) = provider else {
                fatalError("Wrong provider")
            }
            return .init(idToken: idToken, deviceToken: deviceToken, nick: nick)
        }
        
        func toKakaoRequest() -> SignInKakaoRequest {
            guard case .kakao(let oauthToken) = provider else {
                fatalError("Wrong provider")
            }
            return .init(oauthToken: oauthToken, deviceToken: deviceToken)
        }
    }
}
