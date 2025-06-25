//
//  LoginViewStore.swift
//  GLINT-iOS
//
//  Created by System on 6/29/25.
//

import SwiftUI
import Combine

enum LoginState: Equatable {
    case idle
    case loading
    case success
    case failure(String)
}

@Observable
final class LoginViewStore {
    var email: String = ""
    var password: String = ""
    var loginState: LoginState = .idle
    var isEmailValid: Bool = true
    var isPasswordValid: Bool = true
    
    
    private let useCase: LoginViewUseCase
    
    init(useCase: LoginViewUseCase) {
        self.useCase = useCase
    }
    
    // MARK: - 서버 이메일 중복/유효성 검사
    @MainActor
    func checkEmailAvailability() async {
        guard Validator.isValidEmailFormat(email) else {
            isEmailValid = false
            return
        }
        isEmailValid = true
        
        loginState = .loading
        
        do {
            try await useCase.checkEmailValidation(email)
            isEmailValid = true
            loginState = .idle
            print("서버 이메일 유효성 검사 성공 (ViewModel)")
        } catch {
            loginState = .failure("이메일 검사 실패: \(error.localizedDescription)")
            print("서버 이메일 유효성 검사 실패 (ViewModel): \(error.localizedDescription)")
        }
    }
    
    // MARK: - 회원가입 메서드
    @MainActor
    func signUp() async {
        validateInputs()
        
        guard isEmailValid, isPasswordValid else {
            loginState = .failure("입력 정보를 확인해주세요.")
            return
        }
        
        guard !email.isEmpty, !password.isEmpty else {
            loginState = .failure("이메일과 비밀번호를 모두 입력해주세요.")
            return
        }
        
        loginState = .loading
        
        do {
            let response = try await useCase.signUp(email, password, "anonymous")
            loginState = .success
        } catch {
            loginState = .failure("회원가입 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 로그인 메서드
    @MainActor
    func loginWithEmail() async {
        validateInputs()
        
        guard isEmailValid, isPasswordValid else {
            loginState = .failure("입력 정보를 확인해주세요.")
            return
        }
        
        guard !email.isEmpty, !password.isEmpty else {
            loginState = .failure("이메일과 비밀번호를 입력해주세요.")
            return
        }
        
        loginState = .loading
        
        do {
            let response = try await useCase.signIn(email, password)
            loginState = .success
        } catch {
            loginState = .failure("로그인 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Apple 로그인 메서드
    @MainActor
    func appleLogin() async {
        loginState = .loading
        
        do {
            let response = try await useCase.signInApple()
            loginState = .success
        } catch {
            loginState = .failure("Apple 로그인 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 계정 생성 화면 이동 요청
    func navigateToCreateAccount() {
        print("회원가입 화면으로 이동 요청 (ViewModel)")
    }
}

extension LoginViewStore {
    // email, password 유효 여부 UI 반영
    @MainActor
    func validateInputs() {
        isEmailValid = email.isEmpty ? true : Validator.isValidEmailFormat(email)
        isPasswordValid = password.isEmpty ? true : Validator.isValidPasswordFormat(password)
    }
}
