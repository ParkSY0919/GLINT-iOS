//
//  CommunityViewUseCaseKey.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/26/25.
//

import SwiftUI

// MARK: - Environment Key
struct CommunityViewUseCaseKey: EnvironmentKey {
    static let defaultValue: CommunityViewUseCase = .liveValue
}

extension EnvironmentValues {
    var communityViewUseCase: CommunityViewUseCase {
        get { self[CommunityViewUseCaseKey.self] }
        set { self[CommunityViewUseCaseKey.self] = newValue }
    }
}