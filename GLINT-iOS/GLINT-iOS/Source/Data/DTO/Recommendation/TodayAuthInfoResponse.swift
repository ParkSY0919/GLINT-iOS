//
//  TodayAuthInfoResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/3/25.
//

import Foundation

struct TodayAuthInfoResponse: ResponseData {
    let userID, nick, name, introduction: String
    let description: String
    let profileImage: String
    var profileImageURL: String {
        return self.profileImage.imageURL
    }
    let hashTags: [String]
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, name, introduction
        case description, profileImage, hashTags
    }
}
