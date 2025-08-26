//
//  CommunityViewUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/26/25.
//

import Foundation

struct CommunityViewUseCase {
    var loadCommunityItems: @Sendable () async throws -> [FilterEntity]
}