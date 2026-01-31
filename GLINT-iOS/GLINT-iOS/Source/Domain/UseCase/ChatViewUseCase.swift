//
//  ChatViewUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/9/25.
//

import Foundation

struct ChatViewUseCase {
    var infoChatRooms: @Sendable () async throws -> [ChatRoomEntity]
    var chatRoomFileUpload: @Sendable (_ roomID: String, _ files: [Data]) async throws -> [String]
    var getChatHistory: @Sendable (_ roomID: String, _ next: String) async throws -> [ChatEntity]
    var postChatMessage: @Sendable (_ roomID: String, _ content: String, _ files: [String]?) async throws -> ChatEntity
    var chatPushNoti: @Sendable (_ userIds: [String], _ title: String, _ body: String) async throws -> Void
}
