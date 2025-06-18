//
//  SignInAppleDTO.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import Foundation

struct SignInAppleDTO: RequestData {
    let idToken: String
    let deviceToken: String
    let nick: String
}

extension SocialLoginEntity.Request {
    func toAppleDTO() -> SignInAppleDTO {
        guard case .apple(let idToken, let nick) = provider else {
            fatalError("Wrong provider")
        }
        return .init(idToken: idToken, deviceToken: deviceToken, nick: nick)
    }
}
