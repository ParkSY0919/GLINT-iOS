//
//  FilterDetailCommentResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/2/25.
//

import Foundation

// MARK: - Comment
struct FilterDetailCommentResponse: ResponseData {
    let commentID, content, createdAt: String
    let creator: ProfileEntity
    let replies: [FilterDetailCommentResponse]?
    
    enum CodingKeys: String, CodingKey {
        case commentID = "comment_id"
        case content, createdAt, creator, replies
    }
}
