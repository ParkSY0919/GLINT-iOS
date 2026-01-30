//
//  ChatRoomResponse+Entity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

extension ChatRoomResponse {
    func toEntity() -> ChatRoomEntity {
        return .init(
            id: self.roomID,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            participants: self.participants.map { $0.toProfileEntity() },
            lastChat: self.lastChat?.toEntity()
        )
    }
}
