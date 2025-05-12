//
//  Font+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/10/25.
//

import SwiftUI

enum PointFontName {
    case title_32
    case body_20
    case caption_14
    
    var rawValue: String {
        switch self {
        case .title_32:
            return "TTHakgyoansimMulgyeolB"
        case .body_20:
            return "OTHakgyoansimMulgyeolB"
        case .caption_14:
            return "TTHakgyoansimMulgyeolR"
        }
    }
    
    var size: CGFloat {
        switch self {
        case .title_32:
            return 32
        case .body_20:
            return 20
        case .caption_14:
            return 14
        }
    }
}

enum PretendardFontName {
    case title_20
    case body1_16, body2_14, body3_13
    case caption1_12, caption2_10, caption3_8
    
    var rawValue: String {
        switch self {
        case .title_20:
            return "Pretendard-Bold"
        case .body1_16, .body2_14, .body3_13:
            return "Pretendard-Medium"
        case .caption1_12, .caption2_10, .caption3_8:
            return "Pretendard-Regular"
        }
    }
    
    var size: CGFloat {
        switch self {
        case .title_20:
            return 20
        case .body1_16:
            return 16
        case .body2_14:
            return 14
        case .body3_13:
            return 13
        case .caption1_12:
            return 12
        case .caption2_10:
            return 10
        case .caption3_8:
            return 8
        }
    }
}

extension Font {
    static func pointFont(_ style: PointFontName) -> Font {
        return Font.custom(style.rawValue, size: style.size)
    }
    
    static func pretendardFont(_ style: PretendardFontName) -> Font {
        return Font.custom(style.rawValue, size: style.size)
    }
}


//TODO: 추후 수정
extension Font {
    static let fieldLabel = Font.system(size: 14, weight: .medium)
    static let textFieldFont = Font.system(size: 16)
    static let buttonFont = Font.system(size: 17, weight: .semibold)
    static let orSignInWithFont = Font.system(size: 14)
}
