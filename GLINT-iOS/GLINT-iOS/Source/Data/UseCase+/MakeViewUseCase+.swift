//
//  MakeViewUseCase+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/10/25.
//

import SwiftUI

extension MakeViewUseCase {
    static let liveValue: MakeViewUseCase = {
        let repo: FilterRepository = .value
        return MakeViewUseCase(
            files: { files in
                let request = files
                let response = try await repo.filterFiles(request)
                return response
            }
        )
    }()
}

struct MakeViewUseCaseKey: EnvironmentKey {
    static let defaultValue: MakeViewUseCase = .liveValue
}

extension EnvironmentValues {
    var makeViewUseCase: MakeViewUseCase {
        get { self[MakeViewUseCaseKey.self] }
        set { self[MakeViewUseCaseKey.self] = newValue }
    }
}
