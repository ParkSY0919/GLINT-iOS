//
//  SignUpRequest.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/15/25.
//

import Foundation

struct SignUpRequest: Codable {
    let email, password, nick, name: String
    let introduction, phoneNum: String
    let hashTags: [String]
    let deviceToken: String
}
