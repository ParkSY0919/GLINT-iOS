//
//  TodayAuthorResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/19/25.
//

import Foundation

struct TodayAuthorResponse: ResponseData {
    let author: TodayAuthInfo
    let filters: [FilterSummary]
}

struct TodayAuthInfo: ResponseData {
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
