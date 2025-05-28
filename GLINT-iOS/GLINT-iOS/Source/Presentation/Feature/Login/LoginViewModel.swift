//
//  LoginViewModel.swift
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
final class LoginViewModel {
    var email: String = ""
    var password: String = ""
    var loginState: LoginState = .idle
    var isEmailValidForUI: Bool = true
    var isPasswordValid: Bool = true
    
    // MARK: - UseCases (Struct 기반)
    private let userUseCase: UserUseCase
    private let keychain: KeychainProvider
    
    init(userUseCase: UserUseCase = .liveValue, keychain: KeychainProvider = .shared) {
        self.userUseCase = userUseCase
        self.keychain = keychain
        keychain.saveDeviceUUID()
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
    
    // MARK: - 실시간 유효성 검사 (View에서 호출하므로 public)
    func validateInputs() {
        isEmailValidForUI = email.isEmpty ? true : validateEmailFormat(email)
        isPasswordValid = password.isEmpty ? true : validatePasswordFormat(password)
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
            loginState = .idle
            print("서버 이메일 유효성 검사 성공 (ViewModel)")
        } catch {
            loginState = .failure("이메일 검사 실패: \(error.localizedDescription)")
            print("서버 이메일 유효성 검사 실패 (ViewModel): \(error.localizedDescription)")
        }
    }
    
    // MARK: - 회원가입 메서드 (UseCase 사용)
    @MainActor
    func signUp() async {
        validateInputs()
        
        guard isEmailValidForUI, isPasswordValid else {
            loginState = .failure("입력 정보를 확인해주세요.")
            return
        }
        
        guard !email.isEmpty, !password.isEmpty else {
            loginState = .failure("이메일과 비밀번호를 입력해주세요.")
            return
        }
        
        loginState = .loading
        
        // deviceToken 가져오기
        guard let deviceToken = keychain.getDeviceUUID() else {
            loginState = .failure("디바이스 ID를 찾을 수 없습니다.")
            return
        }
        
        let request = SignUpRequest(
            email: email,
            password: password,
            nick: "psy",  // TODO: 실제 닉네임 입력받기
            deviceToken: deviceToken
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
        validateInputs()
        
        guard isEmailValidForUI, isPasswordValid else {
            loginState = .failure("입력 정보를 확인해주세요.")
            return
        }
        
        guard !email.isEmpty, !password.isEmpty else {
            loginState = .failure("이메일과 비밀번호를 입력해주세요.")
            return
        }
        
        loginState = .loading
        
        guard let deviceId = keychain.getDeviceUUID() else {
            loginState = .failure("디바이스 ID를 찾을 수 없습니다.")
            print("deviceId 없음")
            return
        }
        
        let request = SignInRequest(email: email, password: password, deviceToken: deviceId)
        
        do {
            let response = try await userUseCase.signIn(request)
            loginState = .success
            print("response: \n\(response)")
        } catch {
            loginState = .failure("일반 로그인 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Apple 로그인 메서드
    @MainActor
    func appleLogin() async {
        loginState = .loading
        
        do {
            // 애플 로그인 요청
            let manager = LoginManager()
            let socialLoginResponse = try await manager.appleLogin()
            
            // deviceToken 가져오기
            guard let deviceToken = keychain.getDeviceUUID() else {
                loginState = .failure("디바이스 ID를 찾을 수 없습니다.")
                return
            }
            
            // SocialLoginResponse에서 필요한 데이터 추출
            let request = SignInRequestForApple(
                idToken: socialLoginResponse.idToken,
                deviceToken: deviceToken,
                nick: "psy"  // TODO: 실제 닉네임 또는 Apple에서 받은 이름 사용
            )
            
            // 서버에 로그인 요청
            let response = try await userUseCase.signInApple(request)
            loginState = .success
            
            
        } catch {
            loginState = .failure("Apple 로그인 실패: \(error.localizedDescription)")
            print("Apple 로그인 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 계정 생성 화면 이동 요청
    func navigateToCreateAccount() {
        print("회원가입 화면으로 이동 요청 (ViewModel)")
        // TODO: 실제 네비게이션 로직 구현
    }
}

// MARK: - Test/Preview용 ViewModel 생성
extension LoginViewModel {
    static func mock() -> LoginViewModel {
        return LoginViewModel(userUseCase: .mockValue)
    }
}
