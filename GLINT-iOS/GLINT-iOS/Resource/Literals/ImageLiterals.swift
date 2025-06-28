//
//  ImageLiterals.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/10/25.
//

import SwiftUI

enum ImageLiterals {}

extension ImageLiterals {
    
    struct TabBar {
        static let home = Image(.home)
        static let homeSelected = Image(.homeFill)
        static let grid = Image(.section)
        static let gridSelected = Image(.sectionFill)
        static let sparkles = Image(.sparkle)
        static let sparklesSelected = Image(.sparkleFill)
        static let search = Image(.search)
        static let searchSelected = Image(.searchFill)
        static let profile = Image(.personTabBar)
        static let profileSelected = Image(.personFillTabBar)
    }
    
    struct Login {
        static let apple = Image(systemName: "apple.logo")
        static let kakao = Image(.kakao)
    }
    
    struct Main {
        static let food = Image(.food)
        static let person = Image(.person)
        static let landscape = Image(.landscape)
        static let nightscape = Image(.nightscape)
        static let star = Image(.star)
    }
    
    struct Detail {
        static let divideBtn = Image(.divideButton)
        static let noMap = Image(.noMap)
        static let filterValues: [Image] = [
            Image(.brightness), Image(.exposure), Image(.contrast), Image(.saturation), Image(.sharpness), Image(.blur),
            Image(.vignette), Image(.noise), Image(.highlights), Image(.shadows), Image(.temperature), Image(.blackPoint)
        ]
        static let like = Image(.like)
        static let likeFill = Image(.likeFill)
    }
    
    struct Make {
        static let upload = Image(.upload)
    }
    
}
