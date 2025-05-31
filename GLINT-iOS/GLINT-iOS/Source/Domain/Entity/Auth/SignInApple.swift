//
//  SignInApple.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/31/25.
//

import Foundation

extension RequestEntity {
    struct SignInApple {
        let idToken, deviceToken, nick: String
        
        func toAppleRequest() -> RequestDTO.SignInForApple {
            return .init(
                idToken: idToken,
                deviceToken: deviceToken,
                nick: nick
            )
        }
    }
}
