//
//  Comment.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/23/25.
//

import Foundation

struct Comment: ResponseData {
    let commentID: String
    let content: String
    let createdAt: String
    let creator: UserInfo
    let replies: [Reply]

    enum CodingKeys: String, CodingKey {
        case commentID = "comment_id"
        case content, createdAt, creator, replies
    }
}
