//
//  ChatResponse+Entity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

extension ChatResponse {
    func toEntity() -> ChatEntity {
        return .init(
            id: self.chatID,
            roomID: self.roomID,
            content: self.content,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            sender: self.sender.toProfileEntity(),
            files: self.files
        )
    }
}
