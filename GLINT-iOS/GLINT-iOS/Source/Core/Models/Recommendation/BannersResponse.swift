//
//  BannersResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 8/9/25.
//

import Foundation

struct BannerListResponse: ResponseData {
    let data: [BannerResponse]
}

struct BannerResponse: ResponseData {
    let name: String
    let imageUrl: String
    let payload: PayloadResponse
    var bannerImageURL: String {
        return self.imageUrl.imageURL
    }
}

struct PayloadResponse: ResponseData {
    let type: String
    let value: String
}
