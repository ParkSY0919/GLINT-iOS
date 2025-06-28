//
//  LoginView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI
import Combine

struct LoginView: View {
    @State
    private var viewModel: LoginViewStore
    private var rootRouter: RootRouter
    
    init(useCase: LoginViewUseCase, rootRouter: RootRouter) {
        self._viewModel = State(initialValue: LoginViewStore(useCase: useCase))
        self.rootRouter = rootRouter
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundSection
                
                VStack(spacing: 20) {
                    formFieldsSection
                    signInSection
                    signUpSection
                    socialLoginSection
                }
                .padding()
                .disabled(viewModel.loginState == .loading)
                
                if viewModel.loginState == .loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
            .onChange(of: viewModel.loginState) { _, newState in
                if newState == .success {
                    print("로그인 성공! (View) - TabBar로 전환")
                    rootRouter.navigate(to: .tabBar)
                }
            }
            .systemNavigationBarHidden()
        }
    }
}

// MARK: - Configure Views
private extension LoginView {
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
                errorMessage: !viewModel.email.isEmpty && !viewModel.isEmailValid
                ? "유효한 이메일을 입력해주세요" : nil,
                text: $viewModel.email
            )
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .onSubmit {
                Task { await viewModel.checkEmailAvailability() }
            }
            .onChange(of: viewModel.email) { _, _ in
                viewModel.validateInputs()
            }
            
            FormFieldView(
                formCase: .password,
                isSecure: true,
                errorMessage: !viewModel.password.isEmpty && !viewModel.isPasswordValid
                ? "8자 이상, 특수문자를 포함해주세요" : nil,
                text: $viewModel.password
            )
            .onChange(of: viewModel.password) { _, _ in
                viewModel.validateInputs()
            }
        }
    }
    
    var signInSection: some View {
        VStack(spacing: 8) {
            Button("Sign in") {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                Task {
                    await viewModel.loginWithEmail()
                }
            }
            .buttonStyle(GLCTAButton())
            .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty || !viewModel.isEmailValid || !viewModel.isPasswordValid || viewModel.loginState == .loading)
            .padding(.top, 30)
            
            if case .failure(let message) = viewModel.loginState {
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
                viewModel.navigateToCreateAccount()
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
                Task {
                    await viewModel.appleLogin()
                }
            }
            SocialLoginButtonView(type: .kakao) {
                // TODO: Kakao 로그인 구현
            }
        }
    }
}

#Preview {
    LoginView(useCase: .liveValue, rootRouter: RootRouter())
}
