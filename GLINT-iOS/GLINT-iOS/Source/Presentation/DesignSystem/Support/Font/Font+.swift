//
//  Font+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/10/25.
//

import SwiftUI

enum PointFontName {
    case title
    case body
    case caption
    
    var rawValue: String {
        switch self {
        case .title:
            return "TTHakgyoansimMulgyeolB"
        case .body:
            return "OTHakgyoansimMulgyeolB"
        case .caption:
            return "TTHakgyoansimMulgyeolR"
        }
    }
}

enum PretendardFontName {
    case title_bold
    case body_bold, body_medium
    case caption, caption_medium, caption_semi
    
    var rawValue: String {
        switch self {
        case .title_bold, .body_bold, .caption_semi:
            return "Pretendard-Bold"
        case .body_medium, .caption_medium:
            return "Pretendard-Medium"
        case .caption:
            return "Pretendard-Regular"
        }
    }
}

extension Font {
    static func pointFont(_ style: PointFontName, size: CGFloat) -> Font {
        return Font.custom(style.rawValue, size: size)
    }
    
    static func pretendardFont(_ style: PretendardFontName, size: CGFloat) -> Font {
        return Font.custom(style.rawValue, size: size)
    }
}


//TODO: 추후 수정
extension Font {
    static let fieldLabel = Font.system(size: 14, weight: .medium)
    static let textFieldFont = Font.system(size: 16)
    static let buttonFont = Font.system(size: 17, weight: .semibold)
    static let orSignInWithFont = Font.system(size: 14)
}
