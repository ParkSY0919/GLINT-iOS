//
//  TodayFilterEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/29/25.
//

import Foundation

extension ResponseEntity {
    struct TodayFilter: Codable {
        let filterID, title, introduction, description: String
        let original: String?
        let filtered: String?
    }
}
