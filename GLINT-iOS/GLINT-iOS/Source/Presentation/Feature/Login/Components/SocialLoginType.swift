//
//  SocialLoginType.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

enum SocialLoginType {
    case apple, kakao
    
    var icon: Image {
        switch self {
        case .apple:
            return ImageLiterals.Login.apple
        case .kakao:
            return ImageLiterals.Login.kakao
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .apple: return .black
        case .kakao: return .kakaoBg
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .apple: return .white
        case .kakao: return .black
        }
    }
}

