//
//  ChatEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

struct ChatEntity: Identifiable {
    let id: String
    let roomID: String
    let content: String
    let createdAt: String
    let updatedAt: String
    let sender: ProfileEntity
    let files: [String]
}
