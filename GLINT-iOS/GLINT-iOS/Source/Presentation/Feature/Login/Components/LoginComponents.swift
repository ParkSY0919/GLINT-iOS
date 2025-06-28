//
//  LoginComponents.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

struct FormFieldView: View {
    
    enum FormFieldCase {
        case email
        case password
        
        var label : String {
            switch self {
            case .email:
                return "Email"
            case .password:
                return "Password"
            }
        }
        
        var placeholder : String {
            switch self {
            case .email:
                return "Enter your email"
            case .password:
                return "Enter your password"
            }
        }
    }
    
    let formCase: FormFieldCase
    var isSecure: Bool = false
    var errorMessage: String? = nil
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formCase.label)
                .font(.fieldLabel)
                .foregroundColor(.gray0)
            
            if isSecure {
                formFieldStyle(SecureField(formCase.placeholder, text: $text))
            } else {
                formFieldStyle(TextField(formCase.placeholder, text: $text))
            }
            
            HStack {
                Spacer()
                
                if let errorMessage = errorMessage, !text.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .padding(.bottom, -50)
                        .padding(.trailing, 4)
                }
            }
        }
    }
    
    private func formFieldStyle<Content: View>(_ content: Content) -> some View {
        content
            .padding()
            .background(.gray60) // 이전 정의 사용
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
