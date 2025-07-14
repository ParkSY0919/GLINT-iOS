//
//  ChatViewUseCaseKey.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/9/25.
//

import SwiftUI

struct ChatViewUseCaseKey: EnvironmentKey {
    static let defaultValue: ChatViewUseCase = .liveValue
}

extension EnvironmentValues {
    var chatViewUseCase: ChatViewUseCase {
        get { self[ChatViewUseCaseKey.self] }
        set { self[ChatViewUseCaseKey.self] = newValue }
    }
}
