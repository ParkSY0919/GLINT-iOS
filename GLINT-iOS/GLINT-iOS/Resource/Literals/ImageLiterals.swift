//
//  ImageLiterals.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/10/25.
//

import SwiftUI

enum ImageLiterals {}

extension ImageLiterals {
    
    struct TabBarImageLiterals {
        static let home = Image(.home)
        static let homeSelected = Image(.homeFill)
        static let grid = Image(.section)
        static let gridSelected = Image(.sectionFill)
        static let sparkles = Image(.sparkle)
        static let sparklesSelected = Image(.sparkleFill)
        static let search = Image(.search)
        static let searchSelected = Image(.searchFill)
        static let profile = Image(.person)
        static let profileSelected = Image(.personFill)
    }
    
    struct LoginImageLiterals {
        static let apple = Image(systemName: "apple.logo")
        static let kakao = Image(.kakao)
    }
    
}
