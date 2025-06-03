//
//  UserInfoMapper.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/2/25.
//

import Foundation

struct UserInfoMapper {
    static func map(from response: AuthorResponse) -> UserInfoModel {
        return UserInfoModel(
            userID: response.userID,
            name: response.nick ?? "",
            introduction: response.name ?? "",
            description: response.introduction ?? "",
            nick: response.description ?? "",
            profileImage: response.profileImage?.imageURL ?? "",
            hashTags: response.hashTags ?? []
        )
    }
    
    static func map(from response: FilterDetailResponse) -> UserInfoModel {
        return UserInfoModel(
            userID: response.creator.userID,
            name: response.creator.name ?? "",
            introduction: response.creator.introduction ?? "",
            description: response.creator.description ?? "",
            nick: response.creator.nick ?? "",
            profileImage: response.creator.profileImage ?? "",
            hashTags: response.creator.hashTags ?? []
        )
    }
}
