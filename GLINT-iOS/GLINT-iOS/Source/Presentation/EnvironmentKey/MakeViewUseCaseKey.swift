//
//  MakeViewUseCaseKey.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/23/25.
//

import SwiftUI

struct MakeViewUseCaseKey: EnvironmentKey {
    static let defaultValue: MakeViewUseCase = .liveValue
}

extension EnvironmentValues {
    var makeViewUseCase: MakeViewUseCase {
        get { self[MakeViewUseCaseKey.self] }
        set { self[MakeViewUseCaseKey.self] = newValue }
    }
}
