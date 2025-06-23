//
//  MakeViewUseCase+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/10/25.
//

import Foundation

extension MakeViewUseCase {
    static let liveValue: MakeViewUseCase = {
        let repo: FilterRepository = .value
        return MakeViewUseCase(
            files: { files in
                let response = try await repo.filterFiles(files)
                return response
            }
        )
    }()
}


