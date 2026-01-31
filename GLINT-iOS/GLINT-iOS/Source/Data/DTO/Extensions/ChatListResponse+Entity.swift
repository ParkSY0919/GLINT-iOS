//
//  ChatListResponse+Entity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

extension ChatListResponse {
    func toEntity() -> ChatListEntity {
        return .init(
            chats: self.data.map { $0.toEntity() }
        )
    }
}
