//
//  SignInAppleRequest.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import Foundation

struct SignInAppleRequest: RequestData {
    let idToken: String
    let deviceToken: String
    let nick: String
}
