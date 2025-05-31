//
//  HotTrendDTO.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/31/25.
//

import Foundation

extension ResponseDTO {
    //TODO: HotTrendDTO와 TodayAuthorDTO에서 같은 모델을 사용하고 있으니 분리하기.
    struct HotTrend: Codable {
        let data: [Filter]
        
        func toEntity() -> ResponseEntity.HotTrend {
            return .init(data: data.map { $0.toEntity() })
        }
    }
}
