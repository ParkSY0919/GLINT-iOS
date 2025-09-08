//
//  SocialLoginButtonStyle.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

struct GLSocialLoginButton: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color

    init(backgroundColor: Color = .gray100, foregroundColor: Color = .gray0) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
//            .font(.system(size: 24)) // 아이콘 크기
            .frame(width: 100, height: 40) // 버튼 크기
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .roundedRectangleStroke(radius: 8, color: .gray0)
    }
}
