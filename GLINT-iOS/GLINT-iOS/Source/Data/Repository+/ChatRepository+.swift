//
//  ChatRepository+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/9/25.
//

import Foundation

extension ChatRepository {
    static let liveValue: ChatRepository = {
        let provider = NetworkService<ChatEndPoint>()

        return ChatRepository(
            createChatRoom: { userID in
                let response: ChatRoomResponse = try await provider.request(.createChatRoom(userID: userID))
                return response.toEntity()
            },

            infoChatRooms: {
                let response: [ChatRoomResponse] = try await provider.request(.infoChatRooms)
                return response.map { $0.toEntity() }
            },

            chatRoomFileUpload: { roomID, files in
                let response: FileUploadResponse = try await provider.requestMultipart(.filesUpload(roomID: roomID, files: files))
                return response.toEntity()
            },

            getChatHistory: { roomID, next in
                let response: ChatListResponse = try await provider.request(.getChatHistory(roomID: roomID, next: next))
                return response.toEntity()
            },

            postChatMessage: { roomID, content, files in
                let request = PostChatMessageRequest(content: content, files: files)
                let response: ChatResponse = try await provider.request(.postChatMessage(roomID: roomID, request: request))
                return response.toEntity()
            }
        )
    }()
}
