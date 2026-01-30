//
//  TodayAuthorResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/19/25.
//

import Foundation

struct TodayAuthorResponse: ResponseData {
    let author: TodayAuthInfoResponse
    let filters: [FilterSummaryResponse]
}
