//
//  ChatViewUseCase+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/9/25.
//

import Foundation

extension ChatViewUseCase {
    static let liveValue: ChatViewUseCase = {
        let chatRepo: ChatRepository = .liveValue
        let notiRepo: NotificationRepository = .liveValue

        return ChatViewUseCase(
            infoChatRooms: {
                return try await chatRepo.infoChatRooms()
            },
            chatRoomFileUpload: { roomID, files in
                let entity = try await chatRepo.chatRoomFileUpload(roomID, files)
                return entity.files
            },
            getChatHistory: { roomID, next in
                let entity = try await chatRepo.getChatHistory(roomID, next)
                return entity.chats
            },
            postChatMessage: { roomID, content, files in
                return try await chatRepo.postChatMessage(roomID, content, files)
            },
            chatPushNoti: { userIds, title, body in
                return try await notiRepo.push(userIds, title, body)
            }
        )
    }()
}
