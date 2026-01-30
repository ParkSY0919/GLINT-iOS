//
//  MakeViewUseCase+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/10/25.
//

import Foundation

extension MakeViewUseCase {
    static let liveValue: MakeViewUseCase = {
        let filterRepo: FilterRepository = .liveValue

        return MakeViewUseCase(
            files: { files in
                let entity = try await filterRepo.fileUpload(files)
                return Array(entity.files.reversed())
            },
            createFilter: { request in
                let entity = try await filterRepo.createFilter(request)
                return (title: entity.title ?? "", filterID: entity.id)
            }
        )
    }()
}


