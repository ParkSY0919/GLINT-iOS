//
//  ChatRoomEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

struct ChatRoomEntity: Identifiable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let participants: [ProfileEntity]
    let lastChat: ChatEntity?
}
