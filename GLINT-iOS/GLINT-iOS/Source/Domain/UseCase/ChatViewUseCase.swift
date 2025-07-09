//
//  ChatViewUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/9/25.
//

import Foundation

struct ChatViewUseCase {
    var infoChatRooms: @Sendable () async throws -> [ChatRoomResponse]
    var chatRoomFileUpload: @Sendable (_ roomID: String, _ files: [Data]) async throws -> [String]
    var getChatHistory: @Sendable (_ roomID: String, _ next: String) async throws -> [ChatResponse]
    var postChatMessage: @Sendable (_ roomID: String, _ request: PostChatMessageRequest) async throws -> ChatResponse
}
