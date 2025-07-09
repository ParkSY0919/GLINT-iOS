//
//  ChatRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/9/25.
//

import Foundation

struct ChatRepository {
    var createChatRoom: (_ userID: String) async throws -> ChatRoomResponse
    var infoChatRooms: () async throws -> [ChatRoomResponse]
    var chatRoomFileUpload: (_ roomID: String, _ files: [Data]) async throws -> FileUploadResponse
    var getChatHistory: (_ roomID: String, _ next: String) async throws -> ChatListResponse
    var postChatMessage: (_ roomID: String, _ request: PostChatMessageRequest) async throws -> ChatResponse
}
