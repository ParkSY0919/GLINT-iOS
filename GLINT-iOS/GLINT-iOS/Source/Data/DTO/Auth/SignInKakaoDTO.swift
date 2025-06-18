//
//  SignInKakaoDTO.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import Foundation

struct SignInKakaoDTO: RequestData {
    let oauthToken: String
    let deviceToken: String
}

extension SocialLoginEntity.Request {
    func toKakaoDTO() -> SignInKakaoDTO {
        guard case .kakao(let oauthToken) = provider else {
            fatalError("Wrong provider")
        }
        return .init(oauthToken: oauthToken, deviceToken: deviceToken)
    }
}
