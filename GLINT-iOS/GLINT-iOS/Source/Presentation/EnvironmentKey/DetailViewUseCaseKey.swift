//
//  DetailViewUseCaseKey.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/23/25.
//

import SwiftUI

struct DetailViewUseCaseKey: EnvironmentKey {
    static let defaultValue: DetailViewUseCase = .liveValue
}

extension EnvironmentValues {
    var detailViewUseCase: DetailViewUseCase {
        get { self[DetailViewUseCaseKey.self] }
        set { self[DetailViewUseCaseKey.self] = newValue }
    }
}
