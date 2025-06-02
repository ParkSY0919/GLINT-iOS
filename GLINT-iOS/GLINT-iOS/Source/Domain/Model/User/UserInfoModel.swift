//
//  UserInfoModel.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/2/25.
//

import Foundation

struct UserInfoModel: Codable {
    let userID, name, introduction: String
    let description, nick: String
    let profileImage: String
    let hashTags: [String]
}
