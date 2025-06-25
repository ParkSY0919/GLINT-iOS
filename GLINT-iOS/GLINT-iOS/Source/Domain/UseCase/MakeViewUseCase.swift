//
//  MakeViewUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/10/25.
//

import Foundation

struct MakeViewUseCase {
    var files: @Sendable (_ files: [Data]) async throws -> FileUploadResponse
}
