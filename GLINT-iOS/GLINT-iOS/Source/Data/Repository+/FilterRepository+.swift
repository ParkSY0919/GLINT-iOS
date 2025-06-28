//
//  FilterRepository+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/10/25.
//

import Foundation

extension FilterRepository {
    static let liveValue: FilterRepository = {
        let provider = NetworkService<FilterEndPoint>()
        
        return FilterRepository(
            // 파일 업로드
            fileUpload: { files in
                return try await provider.requestMultipart(.filterFiles(files: files))
            }
        )
    }()
}
