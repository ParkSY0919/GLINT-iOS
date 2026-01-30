//
//  SignUpResponse+Entity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

extension SignUpResponse {
    func toEntity() -> AuthEntity {
        return .init(
            userID: self.userID,
            email: self.email,
            nick: self.nick,
            accessToken: self.accessToken,
            refreshToken: self.refreshToken
        )
    }
}
