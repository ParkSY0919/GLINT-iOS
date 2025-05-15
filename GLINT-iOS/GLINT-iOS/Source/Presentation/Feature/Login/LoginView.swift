//
//  LoginView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI
import AuthenticationServices
import Combine

/**
 - state, binding이 데이터 바인딩을 알아서 해주는 어째서 반응형 사용?
 - Rx 카피켓
 - 써드파티 쓸 수 없던 애플이 직접 반응형인 컴바인을 만들었고, 이렇게 만든 @State랑 @Binding을  만들어냈다
 
 */
struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    //MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // 배경 그라데이션
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
                        text: $viewModel.email,
                        placeholder: "Enter your email",
                        errorMessage: !viewModel.isEmailValid ?
                        "유효한 이메일을 입력해주세요" : nil
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    
                    // 패스워드 필드
                    FormFieldView(
                        label: "Password",
                        text: $viewModel.password,
                        placeholder: "Enter your password",
                        isSecure: true,
                        errorMessage: !viewModel.isPasswordValid ?
                        "8자 이상, 특수문자를 포함해주세요" : nil
                    )
                    
                    // 계정 생성 버튼
                    createAccountButton()
                        .padding(.top, 30)
                    
                        
                    // 에러 메시지 표시
                    if case .failure(let message) = viewModel.loginState {
                        Text(message)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.top, 8)
                    }
                    
                    // Or sign in with
                    orSignInWithText()
                    
                    // 소셜 로그인 버튼
                    socialLoginButtons()
                }
                .padding()
                .disabled(viewModel.loginState == .loading)
                
                // 로딩 인디케이터
                if viewModel.loginState == .loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .background(Color.black.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: 80, height: 80)
                }
            }
            .onChange(of: viewModel.loginState) { state in
                if state == .success {
                    // 로그인 성공 시 처리 로직
                    print("로그인 성공!")
                }
            }
        }
    }
    
    
    private func createAccountButton() -> some View {
        Button("Sign in") {
            viewModel.login()
        }
        .buttonStyle(GLCTAButton())
        .disabled(!viewModel.isEmailValid || !viewModel.isPasswordValid)
    }
    
    private func orSignInWithText() -> some View {
        HStack {
            Rectangle()
                .fill(Color(uiColor: .systemGray4))
                .frame(height: 1)
                .frame(maxWidth: .infinity)
            
            Button {
                viewModel.createAccount()
            } label: {
                signUpButton()
            }
            
            Rectangle()
                .fill(Color(uiColor: .systemGray4))
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 4)
        .padding(.top, 30)
    }
    
    private func signUpButton() -> some View {
        Text("회원가입")
            .font(.system(size: 14))
            .foregroundColor(Color(uiColor: .systemGray4))
            .padding(.horizontal, 10)
            .baselineOffset(2)
    }
    
    private func socialLoginButtons() -> some View {
        HStack(spacing: 20) {
            SocialLoginButtonView(type: .apple) {
                viewModel.appleLogin()
            }
            SocialLoginButtonView(type: .kakao) {
                viewModel.kakaoLogin()
            }
        }
    }
}

#Preview {
    LoginView()
}


