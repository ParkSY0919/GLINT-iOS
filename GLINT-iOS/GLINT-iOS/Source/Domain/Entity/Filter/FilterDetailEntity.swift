//
//  FilterDetailEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/2/25.
//

import Foundation

struct FilterDetailEntity: Codable {
    let filter: FilterModel
    let author: UserInfoModel
    let photoMetadata: PhotoMetadataModel
    let filterValues: FilterPresetsModel
    //TODO: 추후 댓글 추가
//    let comments: [FilterDetailComment]
}
