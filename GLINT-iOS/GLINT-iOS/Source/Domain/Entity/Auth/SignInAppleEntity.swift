//
//  SignInAppleEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/31/25.
//

import Foundation

enum SignInAppleEntity {
    struct Request {
        let idToken, deviceToken, nick: String
    }
}
