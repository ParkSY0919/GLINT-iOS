//
//  SignInAppleDTO.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import Foundation

enum SignInAppleDTO {
    struct Request: Codable {
        let idToken, deviceToken, nick: String
    }
}

extension SignInAppleEntity.Request {
    func toDTO() -> SignInAppleDTO.Request {
        return .init(
            idToken: idToken,
            deviceToken: deviceToken,
            nick: nick
        )
    }
}
