//
//  ChatRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/9/25.
//

import Foundation

struct ChatRepository {
    var postChats: (String) async throws -> ChatRoomResponse
    var getChats: () async throws -> [ChatRoomResponse]
}
