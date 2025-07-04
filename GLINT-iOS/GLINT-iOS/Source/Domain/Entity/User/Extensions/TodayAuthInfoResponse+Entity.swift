//
//  TodayAuthInfoResponse+Entity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/3/25.
//

import Foundation

extension TodayAuthInfoResponse {
    func toEntity() -> ProfileEntity {
        return .init(
            userID: self.userID,
            nick: self.nick,
            name: self.name,
            introduction: self.introduction,
            description: self.description,
            profileImageURL: profileImageURL,
            hashTags: nil
        )
    }
}
