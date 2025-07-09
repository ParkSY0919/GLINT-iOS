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
                return try await provider.request(.createChatRoom(userID: userID))
            },
            
            infoChatRooms: {
                return try await provider.request(.infoChatRooms)
            },
            
            chatRoomFileUpload: { roomID, files in
                return try await provider.request(.filesUpload(roomID: roomID, files: files))
            },
            
            getChatHistory: { roomID, next in
                return try await provider.request(.getChatHistory(roomID: roomID, next: next))
            },
            
            postChatMessage: { roomID, request in
                return try await provider.request(.postChatMessage(roomID: roomID, request: request))
            }
        )
    }()
}
