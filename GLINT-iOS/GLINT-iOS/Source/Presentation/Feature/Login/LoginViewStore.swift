//
//  LoginViewStore.swift
//  GLINT-iOS
//
//  Created by System on 6/29/25.
//

import SwiftUI


// MARK: - State
struct LoginViewState {
    var email: String = ""
    var password: String = ""
    var loginState: LoginState = .idle
    var isEmailValid: Bool = true
    var isPasswordValid: Bool = true
}

// MARK: - Action
enum LoginViewAction {
    case viewAppeared
    case emailChanged(String)
    case passwordChanged(String)
    case emailSubmitted
    case signInButtonTapped
    case signUpButtonTapped
    case appleLoginButtonTapped
    case kakaoLoginButtonTapped
    case createAccountButtonTapped
}

// MARK: - LoginState
enum LoginState: Equatable {
    case idle
    case loading
    case success
    case failure(String)
}

// MARK: - Store
@MainActor
@Observable
final class LoginViewStore {
    private(set) var state = LoginViewState()
    private let useCase: LoginViewUseCase
    private weak var rootRouter: RootRouter?
    
    init(useCase: LoginViewUseCase, rootRouter: RootRouter) {
        self.useCase = useCase
        self.rootRouter = rootRouter
    }
    
    func send(_ action: LoginViewAction) {
        switch action {
        case .viewAppeared:
            handleViewAppeared()
            
        case .emailChanged(let email):
            handleEmailChanged(email)
            
        case .passwordChanged(let password):
            handlePasswordChanged(password)
            
        case .emailSubmitted:
            handleEmailSubmitted()
            
        case .signInButtonTapped:
            handleSignInButtonTapped()
            
        case .signUpButtonTapped:
            handleSignUpButtonTapped()
            
        case .appleLoginButtonTapped:
            handleAppleLoginButtonTapped()
            
        case .kakaoLoginButtonTapped:
            handleKakaoLoginButtonTapped()
            
        case .createAccountButtonTapped:
            handleCreateAccountButtonTapped()
        }
    }
}

// MARK: - Private Action Handlers
private extension LoginViewStore {
    func handleViewAppeared() {
        // 뷰가 나타났을 때 필요한 초기화 로직
    }
    
    func handleEmailChanged(_ email: String) {
        state.email = email
        validateInputs()
    }
    
    func handlePasswordChanged(_ password: String) {
        state.password = password
        validateInputs()
    }
    
    func handleEmailSubmitted() {
        Task {
            await checkEmailAvailability()
        }
    }
    
    func handleSignInButtonTapped() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        Task {
            await loginWithEmail()
        }
    }
    
    func handleSignUpButtonTapped() {
        Task {
            await signUp()
        }
    }
    
    func handleAppleLoginButtonTapped() {
        Task {
            await appleLogin()
        }
    }
    
    func handleKakaoLoginButtonTapped() {
        // TODO: Kakao 로그인 구현
        print("Kakao 로그인 버튼 탭됨")
    }
    
    func handleCreateAccountButtonTapped() {
//        rootRouter.navigate(to: .signUp)
    }
    
    func checkEmailAvailability() async {
        guard Validator.isValidEmailFormat(state.email) else {
            state.isEmailValid = false
            return
        }
        state.isEmailValid = true
        state.loginState = .loading
        
        do {
            try await useCase.checkEmailValidation(state.email)
            state.isEmailValid = true
            state.loginState = .idle
            print("서버 이메일 유효성 검사 성공")
        } catch {
            state.loginState = .failure("이메일 검사 실패: \(error.localizedDescription)")
            print("서버 이메일 유효성 검사 실패: \(error.localizedDescription)")
        }
    }
    
    func signUp() async {
        validateInputs()
        
        guard state.isEmailValid, state.isPasswordValid else {
            state.loginState = .failure("입력 정보를 확인해주세요.")
            return
        }
        
        guard !state.email.isEmpty, !state.password.isEmpty else {
            state.loginState = .failure("이메일과 비밀번호를 모두 입력해주세요.")
            return
        }
        
        state.loginState = .loading
        
        do {
            let response = try await useCase.signUp(state.email, state.password, "anonymous")
            state.loginState = .success
            // Store에서 네비게이션 처리
            handleLoginSuccess()
        } catch {
            state.loginState = .failure("회원가입 실패: \(error.localizedDescription)")
        }
    }
    
    func loginWithEmail() async {
        validateInputs()
        
        guard state.isEmailValid, state.isPasswordValid else {
            state.loginState = .failure("입력 정보를 확인해주세요.")
            return
        }
        
        guard !state.email.isEmpty, !state.password.isEmpty else {
            state.loginState = .failure("이메일과 비밀번호를 입력해주세요.")
            return
        }
        
        state.loginState = .loading
        
        do {
            let response = try await useCase.signIn(state.email, state.password)
            state.loginState = .success
            // Store에서 네비게이션 처리
            handleLoginSuccess()
        } catch {
            state.loginState = .failure("로그인 실패: \(error.localizedDescription)")
        }
    }
    
    func appleLogin() async {
        state.loginState = .loading
        
        do {
            let response = try await useCase.signInApple()
            state.loginState = .success
            // Store에서 네비게이션 처리
            handleLoginSuccess()
        } catch {
            state.loginState = .failure("Apple 로그인 실패: \(error.localizedDescription)")
        }
    }
    
    func handleLoginSuccess() {
        // 로그인 성공 시 메인 화면으로 이동
        rootRouter?.navigate(to: .tabBar)
    }
    
    func validateInputs() {
        state.isEmailValid = state.email.isEmpty ? true : Validator.isValidEmailFormat(state.email)
        state.isPasswordValid = state.password.isEmpty ? true : Validator.isValidPasswordFormat(state.password)
    }
}
