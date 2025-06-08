//
//  SignInKakaoDTO.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import Foundation

enum SignInKakaoDTO {
    struct Request: Codable {
        let oauthToken, deviceToken: String
    }
}

extension SignInKakaoEntity.Request {
    func toDTO() -> SignInKakaoDTO.Request {
        return .init(
            oauthToken: oauthToken,
            deviceToken: deviceToken
        )
    }
}
