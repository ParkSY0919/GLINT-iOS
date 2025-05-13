//
//  LoginViewModel.swift
//  GLINT-iOS
//
//  Created by System on 6/29/25.
//

import SwiftUI
import Combine
import AuthenticationServices

enum LoginState: Equatable {
    case idle
    case loading
    case success
    case failure(String)
}

final class LoginViewModel: ObservableObject {
    // MARK: - 입력 관련 프로퍼티
    @Published var email: String = ""
    @Published var password: String = ""
    
    // MARK: - 상태 관련 프로퍼티
    @Published var loginState: LoginState = .idle
    @Published var isEmailValid: Bool = true
    @Published var isPasswordValid: Bool = true
    @Published var errorMessage: String = ""
    
    // MARK: - Combine 관련 프로퍼티
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 초기화
    init() {
        setupBindings()
    }
    
    // MARK: - 바인딩 설정
    private func setupBindings() {
        // 이메일 유효성 검사
        $email
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { [weak self] email in
                self?.validateEmail(email) ?? false
            }
            .assign(to: &$isEmailValid)
        
        // 비밀번호 유효성 검사
        $password
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { [weak self] password in
                self?.validatePassword(password) ?? false
            }
            .assign(to: &$isPasswordValid)
    }
    
    // MARK: - 유효성 검사 메서드
    private func validateEmail(_ email: String) -> Bool {
        guard !email.isEmpty else { return true }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func validatePassword(_ password: String) -> Bool {
        guard !password.isEmpty else { return true }
        
        // 최소 8자 이상, 특수문자 포함
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    // MARK: - 로그인 메서드
    //TODO: 로컬 이메일 로그인
    func login() {
        guard isEmailValid, isPasswordValid else {
            loginState = .failure("유효하지 않은 이메일 또는 비밀번호입니다.")
            return
        }
        
        guard !email.isEmpty, !password.isEmpty else {
            loginState = .failure("이메일과 비밀번호를 입력해주세요.")
            return
        }
        
        loginState = .loading
        
        // 실제 계정 생성 API 연동 코드는 여기에 구현
        // 지금은 시뮬레이션으로 2초 후 성공으로 처리
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.loginState = .success
        }
    }
    
    // MARK: - 소셜 로그인 메서드
    func appleLogin() {
        loginState = .loading
        
        LoginManager.shared.appleLogin()
    }
    
    //TODO: 카카오 로그인
    func kakaoLogin() {
        loginState = .loading
        
        // 실제 카카오 로그인 연동 코드는 여기에 구현
        // 지금은 시뮬레이션으로 2초 후 성공으로 처리
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.loginState = .success
        }
    }
    
    // MARK: - 계정 생성 메서드
    func createAccount() {
        print("회원가입 화면 전환 예정")
    }
} 
