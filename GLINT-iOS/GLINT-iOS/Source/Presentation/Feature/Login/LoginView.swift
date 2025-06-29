//
//  LoginView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(LoginViewStore.self) private var store
    
    var body: some View {
        NavigationStack {
            contentView
            .onAppear {
                store.send(.viewAppeared)
            }
            .navigationSetup(title: "Login")
        }
    }
}

// MARK: - Views
private extension LoginView {
    var contentView: some View {
        ZStack {
            backgroundSection
            
            VStack(spacing: 20) {
                formFieldsSection
                signInSection
                signUpSection
                socialLoginSection
            }
            .padding()
            .disabled(store.state.loginState == .loading)
            
            if store.state.loginState == .loading {
                StateViewBuilder.loadingView()
            }
        }
    }
    
    var backgroundSection: some View {
        LinearGradient(
            gradient: Gradient(colors: [.gray, .bgPoint]),
            startPoint: .topLeading,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    var formFieldsSection: some View {
        VStack(spacing: 20) {
            FormFieldView(
                formCase: .email,
                errorMessage: !store.state.email.isEmpty && !store.state.isEmailValid
                ? "유효한 이메일을 입력해주세요" : nil,
                text: Binding(
                    get: { store.state.email },
                    set: { store.send(.emailChanged($0)) }
                )
            )
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .onSubmit {
                store.send(.emailSubmitted)
            }
            
            FormFieldView(
                formCase: .password,
                isSecure: true,
                errorMessage: !store.state.password.isEmpty && !store.state.isPasswordValid
                ? "8자 이상, 특수문자를 포함해주세요" : nil,
                text: Binding(
                    get: { store.state.password },
                    set: { store.send(.passwordChanged($0)) }
                )
            )
        }
    }
    
    var signInSection: some View {
        VStack(spacing: 8) {
            Button("Sign in") {
                store.send(.signInButtonTapped)
            }
            .buttonStyle(GLCTAButton())
            .disabled(store.state.email.isEmpty ||
                     store.state.password.isEmpty ||
                     !store.state.isEmailValid ||
                     !store.state.isPasswordValid ||
                     store.state.loginState == .loading)
            .padding(.top, 30)
            
            if case .failure(let message) = store.state.loginState {
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
        }
    }
    
    var signUpSection: some View {
        HStack {
            Rectangle().fill(Color(uiColor: .systemGray4)).frame(height: 1)
            Button {
                store.send(.createAccountButtonTapped)
            } label: {
                Text("회원가입")
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
    
    var socialLoginSection: some View {
        HStack(spacing: 20) {
            SocialLoginButtonView(type: .apple) {
                store.send(.appleLoginButtonTapped)
            }
            SocialLoginButtonView(type: .kakao) {
                store.send(.kakaoLoginButtonTapped)
            }
        }
    }
}
#Preview {
    LoginView()
        .environment(LoginViewStore(useCase: .liveValue, rootRouter: RootRouter.init()))
}
