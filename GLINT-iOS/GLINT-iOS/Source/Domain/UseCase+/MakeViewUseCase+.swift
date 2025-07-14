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
                let response = try await Array(filterRepo.fileUpload(files).files.reversed())
                return response
            },
            createFilter: { request in
                let response = try await filterRepo.createFilter(request)
                return (title: response.title, filterID: response.filterID)
            }
        )
    }()
}


