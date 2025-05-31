//
//  SignInKakao.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/31/25.
//

import Foundation

extension RequestEntity {
    struct SignInKakao {
        let oauthToken, deviceToken: String
        
        func toKakaoRequest() -> RequestDTO.SignInForKakao {
            return .init(oauthToken: oauthToken, deviceToken: deviceToken)
        }
    }
}
