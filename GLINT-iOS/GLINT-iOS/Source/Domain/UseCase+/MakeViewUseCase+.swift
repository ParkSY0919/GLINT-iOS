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
                let response = try await filterRepo.fileUpload(files).files
                return response
            },
            createFilter: { request in
                let response = try await filterRepo.createFilter(request).title
                return response
            }
        )
    }()
}


