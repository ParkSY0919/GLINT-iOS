//
//  CreateFilterEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

struct CreateFilterEntity {
    let category: String
    let title: String
    let price: Int
    let description: String
    let files: [String]
    let photoMetadata: PhotoMetadataEntity?
    let filterValues: FilterValuesEntity
}
