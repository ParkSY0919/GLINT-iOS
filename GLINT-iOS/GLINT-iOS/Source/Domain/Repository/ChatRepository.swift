//
//  ChatRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/9/25.
//

import Foundation

struct ChatRepository {
    var createChatRoom: (_ userID: String) async throws -> ChatRoomEntity
    var infoChatRooms: () async throws -> [ChatRoomEntity]
    var chatRoomFileUpload: (_ roomID: String, _ files: [Data]) async throws -> FileUploadEntity
    var getChatHistory: (_ roomID: String, _ next: String) async throws -> ChatListEntity
    var postChatMessage: (_ roomID: String, _ content: String, _ files: [String]?) async throws -> ChatEntity
}
