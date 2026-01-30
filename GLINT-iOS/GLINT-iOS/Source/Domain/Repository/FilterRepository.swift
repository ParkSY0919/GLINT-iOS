//
//  FilterRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/10/25.
//

import Foundation

struct FilterRepository {
    var fileUpload: (_ files: [Data]) async throws -> FileUploadEntity
    var createFilter: (_ request: CreateFilterEntity) async throws -> FilterEntity
    var likeFilter: (_ filterID: String, _ likeStatus: Bool) async throws -> LikeEntity
}
