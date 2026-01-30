//
//  HotTrendResponse+Entity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

extension HotTrendResponse {
    func toEntity() -> HotTrendEntity {
        return .init(
            filters: self.data.map { $0.toEntity() }
        )
    }
}
