//
//  FilterDetailEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

struct FilterDetailEntity {
    let filter: FilterEntity
    let creator: ProfileEntity
    let photoMetadata: PhotoMetadataEntity?
    let filterValues: FilterValuesEntity
}
