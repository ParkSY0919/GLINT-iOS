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
                return try await chatRepo.chatRoomFileUpload(roomID, files).files
            },
            getChatHistory: { roomID, next in
                return try await chatRepo.getChatHistory(roomID, next).data
            },
            postChatMessage: { roomID, request in
                return try await chatRepo.postChatMessage(roomID, request)
            },
            chatPushNoti: { userIds, title, body in
                let request = PushRequest(userIds: userIds, title: title, body: body)
                return try await notiRepo.push(request)
            }
        )
    }()
}
