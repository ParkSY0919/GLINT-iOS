//
//  MainViewUseCase.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/8/25.
//

import Foundation

struct MainViewUseCase {
    var loadMainViewState: @Sendable () async throws -> (FilterEntity, [FilterEntity], ProfileEntity, [FilterEntity], [BannerEntity])
}
