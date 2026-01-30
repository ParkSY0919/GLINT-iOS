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
                let response: FileUploadResponse = try await provider.requestMultipart(.filterFiles(files: files))
                return response.toEntity()
            },

            createFilter: { request in
                let dtoRequest = request.toRequest()
                let response: FilterDetailResponse = try await provider.request(.createFilter(request: dtoRequest))
                return response.toFilterEntity()
            },

            // 필터 좋아요
            likeFilter: { filterID, likeStatus in
                let response: LikeFilterResponse = try await provider.request(.likeFilter(filterID: filterID, likeStatus: likeStatus))
                return response.toEntity()
            }
        )
    }()
}
