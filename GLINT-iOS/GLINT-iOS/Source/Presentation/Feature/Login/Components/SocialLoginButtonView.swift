//
//  SocialLoginButtonView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/29/25.
//

import SwiftUI

struct SocialLoginButtonView: View {
    enum SocialLoginType {
        case apple, kakao
        
        var icon: Image {
            switch self {
            case .apple:
                return Images.Login.apple
            case .kakao:
                return Images.Login.kakao
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
    
    let type: SocialLoginType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            loginIconView()
        }
        .buttonStyle(GLSocialLoginButton(
            backgroundColor: type.backgroundColor,
            foregroundColor: type.foregroundColor
        ))
    }
    
    @ViewBuilder
    private func loginIconView() -> some View {
        if type == .kakao {
            type.icon
                .resizable()
                .padding(12)
        } else {
            type.icon
        }
    }
}

#Preview {
    SocialLoginButtonView(type: .apple, action: {})
}
