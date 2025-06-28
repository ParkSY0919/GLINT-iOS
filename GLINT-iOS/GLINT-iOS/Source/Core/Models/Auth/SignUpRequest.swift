//
//  SignUpRequest.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/18/25.
//

import Foundation

struct SignUpRequest: RequestData {
    let email, password, nick, deviceToken: String
}
