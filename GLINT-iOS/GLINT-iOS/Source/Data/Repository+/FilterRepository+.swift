//
//  FilterRepository+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/10/25.
//

import Foundation

extension FilterRepository {
    static let value: FilterRepository = {
        let provider = NetworkService<FilterEndPoint>()
        
        return FilterRepository(
            filterFiles: { files in
                return try await provider.requestAsyncMultipart(.filterFiles(files: files))
            }
        )
    }()
}
