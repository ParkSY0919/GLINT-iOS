//
//  LikeFilterResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/28/25.
//

import Foundation

struct LikeFilterResponse: ResponseData {
    let likeStatus: Bool
    
    enum CodingKeys: String, CodingKey {
        case likeStatus = "like_status"
    }
}
