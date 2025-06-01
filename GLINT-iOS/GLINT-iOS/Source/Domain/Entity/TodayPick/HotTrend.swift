//
//  HotTrend.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/31/25.
//

import Foundation

extension ResponseEntity {
    struct HotTrend: Codable {
        let data: [FilterEntity]
    }
}
