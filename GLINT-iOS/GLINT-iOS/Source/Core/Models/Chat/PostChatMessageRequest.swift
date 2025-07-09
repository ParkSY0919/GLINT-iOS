//
//  PostChatMessageRequest.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/9/25.
//

import Foundation

struct PostChatMessageRequest: RequestData {
    let content: String
    let files: [String]?
}
