//
//  LoginView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI
import AuthenticationServices


struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    //MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.gray, .bgPoint]),
                    startPoint: .topLeading,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // 이메일 필드
                    FormFieldView(
                        label: "Email",
                        text: $email,
                        placeholder: "Enter your email"
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    
                    // 패스워드 필드
                    FormFieldView(
                        label: "Password",
                        text: $password,
                        placeholder: "Enter your password",
                        isSecure: true
                    )
                    
                    // 계정 생성 버튼
                    createAccountButton()
                    
                    // Or sign in with
                    orSignInWithText()
                    
                    // 소셜 로그인 버튼
                    socialLoginButtons()
                }
                .padding()
            }
        }
    }
    
    //MARK: - ViewBuilder
    @ViewBuilder
    private func createAccountButton() -> some View {
        Button("Create Account") {
            // 계정 생성 로직
            print("Email: \(email), Password: \(password)")
        }
        .buttonStyle(PrimaryButtonStyle())
    }
    
    @ViewBuilder
    private func orSignInWithText() -> some View {
        HStack {
            Rectangle()
                .fill(Color(uiColor: .systemGray4))
                .frame(height: 1)
                .frame(maxWidth: .infinity)
            
            Text("Or sign in with")
                .font(.system(size: 14))
                .foregroundColor(Color(uiColor: .systemGray4))
                .padding(.horizontal, 10)
                .baselineOffset(2)
            
            Rectangle()
                .fill(Color(uiColor: .systemGray4))
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 4)
        .padding(.top, 30)
    }
    
    @ViewBuilder
    private func socialLoginButtons() -> some View {
        HStack(spacing: 20) {
            SocialLoginButtonView(type: .apple) {
                print("Sign in with Apple")
            }
            SocialLoginButtonView(type: .kakao) {
                print("Sign in with Google")
            }
        }
    }
}

#Preview {
    LoginView()
}


