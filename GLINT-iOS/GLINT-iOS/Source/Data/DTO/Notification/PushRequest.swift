//
//  PushRequest.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/24/25.
//

import Foundation

//채팅 알림 (no subtitle)
struct PushRequest: RequestData {
    let userIds: [String]
    let title: String
    let body: String

    enum CodingKeys: String, CodingKey {
        case userIds = "user_ids"
        case title
        case body
    }
}
