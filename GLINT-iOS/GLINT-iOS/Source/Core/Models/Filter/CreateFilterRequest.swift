//
//  CreateFilterRequest.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/2/25.
//

import Foundation

struct CreateFilterRequest: RequestData {
    let category: String
    let title: String
    let price: Int
    let description: String
    let files: [String]
    let photoMetadata: PhotoMetadataEntity?
    let filterValues: FilterValuesEntity

    enum CodingKeys: String, CodingKey {
        case category, title, price, description, files
        case photoMetadata = "photo_metadata"
        case filterValues = "filter_values"
    }
}
