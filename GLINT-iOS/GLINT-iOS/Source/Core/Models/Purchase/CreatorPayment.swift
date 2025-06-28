//
//  CreatorPayment.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/24/25.
//

import Foundation

struct CreatorPayment: ResponseData {
    let userID, nick, name, introduction: String
    let profileImage: String?
    let hashTags: [String]

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, name, introduction, profileImage, hashTags
    }
}
