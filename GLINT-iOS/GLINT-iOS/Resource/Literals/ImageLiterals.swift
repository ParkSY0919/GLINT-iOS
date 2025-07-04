//
//  ImageLiterals.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/10/25.
//

import SwiftUI

typealias Images = ImageLiterals

enum ImageLiterals {}

extension Images {
    
    enum TabBar {
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
    
    enum Login {
        static let apple = Image(systemName: "apple.logo")
        static let kakao = Image(.kakao)
    }
    
    enum Main {
        static let food = Image(.food)
        static let person = Image(.person)
        static let landscape = Image(.landscape)
        static let nightscape = Image(.nightscape)
        static let star = Image(.star)
        
        // MARK: - Banner Images
        static let banner1 = Image("banner_image_1")
        static let banner2 = Image("banner_image_2")
        static let banner3 = Image("banner_image_3")
    }
    
    enum Detail {
        static let divideBtn = Image(.divideButton)
        static let noMap = Image(.noMap)
        static let filterValues: [Image] = [
            Image(.brightness), Image(.exposure), Image(.contrast), Image(.saturation), Image(.sharpness), Image(.blur),
            Image(.vignette), Image(.noise), Image(.highlights), Image(.shadows), Image(.temperature), Image(.blackPoint)
        ]
        static let like = Image(.like)
        static let likeFill = Image(.likeFill)
    }
    
    enum Make {
        static let upload = Image(.upload)
    }
    
}
