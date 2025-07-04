//
//  Array+FilterSummaryResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/3/25.
//

import Foundation

extension Array where Element == FilterSummaryResponse {
    func toEntities() -> [FilterEntity] {
        return self.map { $0.toEntity() }
    }
}
