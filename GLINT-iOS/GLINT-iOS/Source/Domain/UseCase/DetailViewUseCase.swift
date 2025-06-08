//
//  DetailViewUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/8/25.
//

import Foundation

struct DetailViewUseCase {
    var filterDetail: @Sendable (_ filterID: String) async throws -> FilterDetailEntity
}
