//
//  SocialLoginButtonStyle.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

struct SocialLoginButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color

    init(backgroundColor: Color = .socialButtonBackground, foregroundColor: Color = .socialButtonForeground) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 24)) // 아이콘 크기
            .frame(width: 50, height: 50) // 버튼 크기
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
