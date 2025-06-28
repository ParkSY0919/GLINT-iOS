//
//  FilterEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/19/25.
//

import Foundation

struct FilterEntity: ResponseData, Identifiable {
    let id: String
    let category, title, introduction, description: String?
    let original: String?
    let filtered: String?
    let isDownloaded, isLiked: Bool?
    let price, likeCount, buyerCount: Int?
    let createdAt, updatedAt: String
}
