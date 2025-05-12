//
//  LoginComponents.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

struct FormFieldView: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.fieldLabel)
                .foregroundColor(.labelText)
            if isSecure {
                formFieldStyle(SecureField(placeholder, text: $text))
            } else {
                formFieldStyle(TextField(placeholder, text: $text))
            }
        }
    }
    
    @ViewBuilder
    private func formFieldStyle<Content: View>(_ content: Content) -> some View {
        content
            .padding()
            .background(Color.textFieldBackground) // 이전 정의 사용
            .cornerRadius(8)
            .font(.textFieldFont)
    }
}

struct SocialLoginButtonView: View {
    let type: SocialLoginType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            loginIconView()
        }
        .buttonStyle(SocialLoginButtonStyle(
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
