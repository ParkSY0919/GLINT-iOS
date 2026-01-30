//
//  SignInRequest.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/19/25.
//

import Foundation

struct SignInRequest: RequestData {
    let email: String
    let password: String
    let deviceToken: String
}
