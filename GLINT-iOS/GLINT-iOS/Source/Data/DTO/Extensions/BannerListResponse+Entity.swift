//
//  BannerListResponse+Entity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 1/30/26.
//

import Foundation

extension BannerListResponse {
    func toEntity() -> BannerListEntity {
        return .init(
            banners: self.data.map { $0.toEntity() }
        )
    }
}
