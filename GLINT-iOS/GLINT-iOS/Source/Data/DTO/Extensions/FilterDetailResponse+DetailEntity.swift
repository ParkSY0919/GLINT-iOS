//
//  FilterDetailResponse+DetailEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

extension FilterDetailResponse {
    func toDetailEntity() -> FilterDetailEntity {
        let filter = self.toFilterEntity()
        let creator = self.creator.toProfileEntity()
        let metadata = self.photoMetadata?.toEntity()
        let presets = self.filterValues.toEntity()

        return FilterDetailEntity(
            filter: filter,
            creator: creator,
            photoMetadata: metadata,
            filterValues: presets
        )
    }
}
