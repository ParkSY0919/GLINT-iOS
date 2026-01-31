//
//  CreateFilterEntity+Request.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

extension CreateFilterEntity {
    func toRequest() -> CreateFilterRequest {
        return .init(
            category: self.category,
            title: self.title,
            price: self.price,
            description: self.description,
            files: self.files,
            photoMetadata: self.photoMetadata,
            filterValues: self.filterValues
        )
    }
}
