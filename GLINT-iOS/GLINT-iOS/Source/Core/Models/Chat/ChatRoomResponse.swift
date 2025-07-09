//
//  ChatRoomResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/9/25.
//

import Foundation

struct ChatRoomResponse: ResponseData {
    let roomID: String
    let createdAt: String
    let updatedAt: String
    let participants: [UserInfoResponse]
    let lastChat: ChatResponse?

    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case createdAt, updatedAt, participants, lastChat
    }
}
