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
            },
            
            createFilter: { request in
                return try await provider.request(.createFilter(request: request))
            },
            
            // 필터 좋아요
            likeFilter: { filterID, likeStatus in
                return try await provider.request(.likeFilter(filterID: filterID, likeStatus: likeStatus))
            }
        )
    }()
}
