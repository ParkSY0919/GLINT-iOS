//
//  LikeFilterResponse+Entity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

extension LikeFilterResponse {
    func toEntity() -> LikeEntity {
        return .init(likeStatus: self.likeStatus)
    }
}
