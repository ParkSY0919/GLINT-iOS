//
//  OrderHistoryEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/11/25.
//

import Foundation

enum OrderHistoryEntity {
    struct Response: ResponseData {
        let data: [Datum]
    }
}
