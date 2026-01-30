//
//  SocialLoginEntity+Request.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

extension SocialLoginEntity.Request {
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
