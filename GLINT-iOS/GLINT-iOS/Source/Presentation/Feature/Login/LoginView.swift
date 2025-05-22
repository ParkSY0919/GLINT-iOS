//
//  LoginView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI
import AuthenticationServices
import Combine

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
//    @Environment(\.userUseCase.)
    
    //MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // 배경 그라데이션
                LinearGradient(
                    gradient: Gradient(colors: [.gray, .bgPoint]),
                    startPoint: .topLeading,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    FormFieldView(
                        formCase: .email,
                        errorMessage: !viewModel.email.isEmpty && !viewModel.isEmailValidForUI
                        ? "유효한 이메일을 입력해주세요" : nil,
                        text: $viewModel.email
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                     .onSubmit { // 키보드의 return 키
                         Task { await viewModel.checkEmailAvailability() }
                     }
                    
                    FormFieldView(
                        formCase: .password,
                        isSecure: true,
                        errorMessage: !viewModel.password.isEmpty && !viewModel.isPasswordValid
                        ? "8자 이상, 특수문자를 포함해주세요" : nil,
                        text: $viewModel.password
                    )
                    
                    signInButton() // 버튼 이름 변경
                        .padding(.top, 30)
                    
                    if case .failure(let message) = viewModel.loginState {
                        Text(message)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.top, 8)
                    }
                    
                    orTextWithSignUpButton() // 함수 이름 변경
                    
                    socialLoginButtons()
                }
                .padding()
                .disabled(viewModel.loginState == .loading)
                
                if viewModel.loginState == .loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
            .onChange(of: viewModel.loginState) { newState in
                if newState == .success {
                    print("로그인 성공! (View) - 다음 화면으로 이동 등 처리")
                    // 예: 메인 화면으로 전환하는 로직
                }
            }
            .navigationTitle("로그인")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    
    private func signInButton() -> some View {
        Button("Sign in") {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            Task {
                await viewModel.loginWithEmail()
            }
        }
        .buttonStyle(GLCTAButton()) // 사용하시는 커스텀 버튼 스타일
        .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty || !viewModel.isEmailValidForUI || !viewModel.isPasswordValid || viewModel.loginState == .loading)
    }
    
    // 함수 이름 변경
    private func orTextWithSignUpButton() -> some View {
        HStack {
            Rectangle().fill(Color(uiColor: .systemGray4)).frame(height: 1)
            Button {
                viewModel.navigateToCreateAccount() // ViewModel 함수 호출
            } label: {
                Text("회원가입") // 직접 텍스트 사용
                    .font(.system(size: 14))
                    .foregroundColor(Color(uiColor: .systemGray4))
                    .padding(.horizontal, 10)
                    .baselineOffset(2)
            }
            Rectangle().fill(Color(uiColor: .systemGray4)).frame(height: 1)
        }
        .padding(.horizontal, 4)
        .padding(.top, 30)
    }
    
    private func socialLoginButtons() -> some View {
        HStack(spacing: 20) {
            SocialLoginButtonView(type: .apple) { // SocialLoginButtonView 정의 필요
                viewModel.appleLogin() // ViewModel 함수 호출
            }
            SocialLoginButtonView(type: .kakao) { // SocialLoginButtonView 정의 필요
                viewModel.kakaoLogin() // ViewModel 함수 호출
            }
        }
    }
}

#Preview {
    LoginView()
}


