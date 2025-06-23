//
//  FilterDetailRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import Foundation

struct FilterDetailRepository {
    var filterDetail: (_ filterId: String) async throws -> FilterResponse
}
