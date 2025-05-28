//
//  LoginViewModel.swift
//  GLINT-iOS
//
//  Created by System on 6/29/25.
//

import SwiftUI
import Combine

final class LoginViewModel: ObservableObject {
    enum LoginState: Equatable {
        case idle
        case loading
        case success
        case failure(String)
    }
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var loginState: LoginState = .idle
    @Published var isEmailValidForUI: Bool = true
    @Published var isPasswordValid: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UseCases (Struct 기반)
    private let userUseCase: UserUseCase
    private let keychain: KeychainProvider
    
    init(userUseCase: UserUseCase = .liveValue, keychain: KeychainProvider = .shared) {
        self.userUseCase = userUseCase
        self.keychain = keychain
        setupEmailValidationBinding()
        keychain.saveDeviceUUID()
    }
    
    private func setupEmailValidationBinding() {
        $email
            .dropFirst()
            .debounce(for: .seconds(0.8), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { emailText -> String? in
                guard !emailText.isEmpty else { return nil }
                return emailText
            }
            .compactMap { $0 }
            .sink { [weak self] emailToValidate in
                self?.isEmailValidForUI = self?.validateEmailFormat(emailToValidate) ?? true
            }
            .store(in: &cancellables)
        
        $password
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { [weak self] passwordText -> Bool in
                guard !passwordText.isEmpty else { return true }
                return self?.validatePasswordFormat(passwordText) ?? false
            }
            .assign(to: &$isPasswordValid)
    }
    
    // MARK: - UI 피드백용 유효성 검사 메서드 (로컬)
    private func validateEmailFormat(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func validatePasswordFormat(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    // MARK: - 서버 이메일 중복/유효성 검사 (UseCase 사용)
    @MainActor
    func checkEmailAvailability() async {
        guard validateEmailFormat(email) else {
            isEmailValidForUI = false
            return
        }
        isEmailValidForUI = true
        
        loginState = .loading
        let request = CheckEmailValidationRequest(email: email)
        
        do {
            let response = try await userUseCase.checkEmailValidation(request)
            loginState = .idle // 성공시 idle로 돌아감
            print("서버 이메일 유효성 검사 성공 (ViewModel)")
        } catch {
            loginState = .failure("이메일 검사 실패: \(error.localizedDescription)")
            print("서버 이메일 유효성 검사 실패 (ViewModel): \(error.localizedDescription)")
        }
    }
    
    // MARK: - 회원가입 메서드 (UseCase 사용)
    @MainActor
    func signUp() async {
        guard isEmailValidForUI, isPasswordValid else {
            loginState = .failure("입력 정보를 확인해주세요.")
            return
        }
        
        guard !email.isEmpty, !password.isEmpty else {
            loginState = .failure("이메일과 비밀번호를 입력해주세요.")
            return
        }
        
        loginState = .loading
        let request = SignUpRequest(
            email: email,
            password: password,
            nick: "psy",
            deviceToken: "mock_psy"
        )
        
        do {
            let response = try await userUseCase.signUp(request)
            loginState = .success
            print("회원가입 성공 (ViewModel): \(response)")
        } catch {
            loginState = .failure("회원가입 실패: \(error.localizedDescription)")
            print("회원가입 실패 (ViewModel): \(error.localizedDescription)")
        }
    }
    
    // MARK: - 일반 로그인 메서드
    @MainActor
    func loginWithEmail() async {
        guard isEmailValidForUI, isPasswordValid else {
            loginState = .failure("입력 정보를 확인해주세요.")
            return
        }
        guard !email.isEmpty, !password.isEmpty else {
            loginState = .failure("이메일과 비밀번호를 입력해주세요.")
            return
        }
        loginState = .loading
        // 실제로는 LoginUseCase 호출
        
        if let deviceId = keychain.getDeviceUUID() {
            let request = SignInRequest(email: email, password: password, deviceToken: deviceId)
            
            do {
                loginState = .success
                let response = try await userUseCase.signIn(request)
                print("response: \n\(response)")
            } catch {
                loginState = .failure("일반 로그인 실패: \(error.localizedDescription)")
            }
        } else {
            print("deviceId 없음")
        }
    }
    
    // MARK: - Apple 로그인 메서드
    @MainActor
    func appleLogin() {
        loginState = .loading
        
        Task {
            // 애플 로그인 요청
            let manager = LoginManager()
            let socialLoginResponse = try await manager.appleLogin()
            
            // SocialLoginResponse에서 필요한 데이터 추출
            let request = SignInRequestForApple(
                idToken: socialLoginResponse.idToken,
                deviceToken: "psyDeviceToken",
                nick: "psy"
            )
            
            // 서버에 로그인 요청
            let response = try await self.userUseCase.signInApple(request)
            self.loginState = .success
            
        }
    }
}

// MARK: - 계정 생성 화면 이동 요청
func navigateToCreateAccount() {
    print("회원가입 화면으로 이동 요청 (ViewModel)")
}


// MARK: - Test/Preview용 ViewModel 생성
extension LoginViewModel {
    static func mock() -> LoginViewModel {
        return LoginViewModel(userUseCase: .mockValue)
    }
}
