//
//  UserInfoResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/20/25.
//

import Foundation

struct UserInfoResponse: ResponseData {
    let userID, nick: String
    let name, introduction, description: String?
    let profileImage: String?
    let hashTags: [String]?
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick
        case name
        case introduction
        case description
        case profileImage
        case hashTags
    }
    
    func toProfileEntity() -> ProfileEntity {
        return .init(
            userID: self.userID,
            nick: self.nick,
            name: self.name,
            introduction: self.introduction,
            description: self.description,
            profileImageURL: profileImage?.imageURL,
            hashTags: self.hashTags
        )
    }
}
