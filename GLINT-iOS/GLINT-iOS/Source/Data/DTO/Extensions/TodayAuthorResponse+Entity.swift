//
//  TodayAuthorResponse+Entity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

extension TodayAuthorResponse {
    func toEntity() -> TodayAuthorEntity {
        return .init(
            author: self.author.toEntity(),
            filters: self.filters.map { $0.toEntity() }
        )
    }
}
