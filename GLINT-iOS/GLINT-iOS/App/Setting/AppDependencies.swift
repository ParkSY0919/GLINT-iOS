//
//  AppDependencies.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/19/25.
//

import Foundation

struct AppDependencies {
    let userUseCase: UserUseCase
    
    static let live = AppDependencies(
        userUseCase: .liveValue
    )
    
    static let mock = AppDependencies(
        userUseCase: .mockValue
    )
}
