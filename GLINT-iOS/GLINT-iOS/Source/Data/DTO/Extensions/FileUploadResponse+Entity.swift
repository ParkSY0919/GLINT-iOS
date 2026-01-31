//
//  FileUploadResponse+Entity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

extension FileUploadResponse {
    func toEntity() -> FileUploadEntity {
        return .init(files: self.files)
    }
}
