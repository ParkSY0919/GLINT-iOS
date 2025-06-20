//
//  UserInfoMapper.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/2/25.
//

import Foundation

struct UserInfoMapper {
    static func map(from response: UserInfo) -> ProfileEntity {
        return ProfileEntity(
            userID: response.userID,
            nick: response.description ?? "", name: response.nick,
            introduction: response.name ?? "",
            description: response.introduction ?? "",
            profileImageURL: response.profileImage?.imageURL ?? "",
            hashTags: response.hashTags
        )
    }
    
    static func map(from response: FilterDetailResponse) -> ProfileEntity {
        return ProfileEntity(
            userID: response.creator.userID,
            nick: response.creator.nick, name: response.creator.name ?? "",
            introduction: response.creator.introduction ?? "",
            description: response.creator.description ?? "",
            profileImageURL: response.creator.profileImage?.imageURL,
            hashTags: response.creator.hashTags
        )
    }
}
