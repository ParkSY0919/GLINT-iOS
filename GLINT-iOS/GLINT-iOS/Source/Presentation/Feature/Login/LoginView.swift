//
//  LoginView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(LoginViewStore.self)
    private var store
    @State private var animateGradient = false
    @State private var showContent = false
    
    var body: some View {
        NavigationStack {
            contentView
                .appScreenStyle(backgroundColor: .pinterestDarkBg, ignoresSafeArea: true)
                .onViewDidLoad(perform: {
                    store.send(.viewAppeared)
                    // Start content animation
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                        showContent = true
                    }
                })
                .navigationSetup(title: "")
                .navigationBarHidden(true)
        }
        .onAppear {
            // Start gradient animation
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

private extension LoginView {
    var contentView: some View {
        ZStack {
            // Animated gradient background
            backgroundGradient
            
            GeometryReader { geometry in
                    VStack(spacing: 0) {
                        // Header section with logo and title
                        headerSection
                            .frame(height: geometry.size.height * 0.4)
                        
                        // Main content card
                        mainContentCard(geometry: geometry)
                    }
                    .frame(minHeight: geometry.size.height)
            }
            
            // Loading overlay
            if store.state.loginState == .loading {
                loadingOverlay
            }
        }
        .ignoresSafeArea(.all)
    }
    
    var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.pinterestDarkBg,
                Color.pinterestDarkSurface,
                animateGradient ? Color.pinterestRedSoft : Color.pinterestDarkBg
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea(.all)
    }
    
    var headerSection: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // App logo/icon placeholder - you can replace with actual logo
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.gradientStart, .gradientMid, .gradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: .pinterestRed.opacity(0.4), radius: 20, x: 0, y: 10)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(showContent ? 1.0 : 0.5)
            .opacity(showContent ? 1.0 : 0.0)
            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1), value: showContent)
            
            VStack(spacing: 8) {
                Text("Welcom GLINT")
                    .font(.pretendardFont(.title_bold, size: 28))
                    .foregroundColor(.pinterestTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("이미지에 나를 입히고, 세상과 나누다")
                    .font(.pretendardFont(.body_medium, size: 16))
                    .foregroundColor(.pinterestTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(showContent ? 1.0 : 0.0)
            .offset(y: showContent ? 0 : 20)
            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: showContent)
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    func mainContentCard(geometry: GeometryProxy) -> some View {
        VStack(spacing: 32) {
            formFieldsSection
            signInSection
            dividerSection
            socialLoginSection
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
        .background(
            ZStack {
                // Glassmorphism card background
                RoundedRectangle(cornerRadius: 32)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.pinterestDarkCard.opacity(0.7))
                    )
                
                // Subtle border
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.glassStroke, lineWidth: 1)
            }
        )
        .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 15)
        .padding(.horizontal, 16)
        .disabled(store.state.loginState == .loading)
        .scaleEffect(showContent ? 1.0 : 0.95)
        .opacity(showContent ? 1.0 : 0.0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5), value: showContent)
    }
    
    var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea(.all)
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .pinterestRed))
                    .scaleEffect(1.5)
                
                Text("로그인 중...")
                    .font(.pretendardFont(.body_medium, size: 16))
                    .foregroundColor(.pinterestTextPrimary)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
        }
    }

    
    var formFieldsSection: some View {
        VStack(spacing: 24) {
            FormFieldView(
                formCase: .email,
                errorMessage: !store.state.email.isEmpty && !store.state.isEmailValid
                ? Strings.Login.Error.emailValidation : nil,
                text: Binding(
                    get: { store.state.email },
                    set: { store.send(.emailChanged($0)) }
                )
            )
            .onSubmit {
                store.send(.emailSubmitted)
            }
            
            FormFieldView(
                formCase: .password,
                errorMessage: !store.state.password.isEmpty && !store.state.isPasswordValid
                ? Strings.Login.Error.passwordValidation : nil,
                text: Binding(
                    get: { store.state.password },
                    set: { store.send(.passwordChanged($0)) }
                )
            )
        }
    }
    
    var signInSection: some View {
        VStack(spacing: 16) {
            modernSignInButton
            
            if case .failure(let message) = store.state.loginState {
                errorMessageView(message: message)
            }
        }
    }
    
    var modernSignInButton: some View {
        Button(action: {
            store.send(.signInButtonTapped)
        }) {
            HStack(spacing: 12) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                
                Text(Strings.Login.signIn)
                    .font(.pretendardFont(.body_bold, size: 18))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    // Main gradient
                    LinearGradient(
                        colors: [.gradientStart, .gradientMid],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    
                    // Overlay for glassmorphism
                    LinearGradient(
                        colors: [.glassLight, .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .pinterestRed.opacity(0.4), radius: 12, x: 0, y: 6)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .scaleEffect(store.state.loginState == .loading ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: store.state.loginState == .loading)
        }
        .disabled(store.state.email.isEmpty ||
                 store.state.password.isEmpty ||
                 !store.state.isEmailValid ||
                 !store.state.isPasswordValid ||
                 store.state.loginState == .loading)
        .opacity((store.state.email.isEmpty ||
                 store.state.password.isEmpty ||
                 !store.state.isEmailValid ||
                 !store.state.isPasswordValid) ? 0.5 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: store.state.email.isEmpty || store.state.password.isEmpty)
    }
    
    func errorMessageView(message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.pinterestError)
            
            Text(message)
                .font(.pretendardFont(.caption_medium, size: 14))
                .foregroundColor(.pinterestError)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.pinterestError.opacity(0.1))
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.pinterestError.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    var dividerSection: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(Color.pinterestTextTertiary.opacity(0.3))
                .frame(height: 1)
            
            Text("또는")
                .font(.pretendardFont(.caption_medium, size: 14))
                .foregroundColor(.pinterestTextTertiary)
                .padding(.horizontal, 8)
            
            Rectangle()
                .fill(Color.pinterestTextTertiary.opacity(0.3))
                .frame(height: 1)
        }
    }
    
    var socialLoginSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                SocialLoginButtonView(type: .apple) {
                    store.send(.appleLoginButtonTapped)
                }
                
                SocialLoginButtonView(type: .kakao) {
                    store.send(.kakaoLoginButtonTapped)
                }
            }
            
            // Sign up link
            Button(action: {
                store.send(.createAccountButtonTapped)
            }) {
                HStack(spacing: 8) {
                    Text("계정이 없으신가요?")
                        .font(.pretendardFont(.caption_medium, size: 14))
                        .foregroundColor(.pinterestTextSecondary)
                    
                    Text(Strings.Login.signUp)
                        .font(.pretendardFont(.caption_semi, size: 14))
                        .foregroundColor(.pinterestRed)
                }
            }
            .padding(.top, 8)
        }
    }
}

#Preview {
    LoginView()
        .environment(LoginViewStore(useCase: .liveValue, rootRouter: RootRouter.init()))
}
