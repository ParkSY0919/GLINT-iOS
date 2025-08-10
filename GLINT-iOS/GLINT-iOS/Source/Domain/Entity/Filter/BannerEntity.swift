//
//  BannerEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 8/9/25.
//

import Foundation

struct BannerEntity: ResponseData, Identifiable, Equatable {
    var id: String { bannerImageURL }
    let name: String
    let payload: PayloadResponse
    let bannerImageURL: String
    
    static func == (lhs: BannerEntity, rhs: BannerEntity) -> Bool {
        return lhs.bannerImageURL == rhs.bannerImageURL && lhs.name == rhs.name
    }
}
