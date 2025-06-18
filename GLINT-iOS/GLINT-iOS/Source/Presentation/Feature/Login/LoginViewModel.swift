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
    
    private let keychain: KeychainManager
    private let useCase: LoginViewUseCase
    
    init(useCase: LoginViewUseCase, keychain: KeychainManager = .shared) {
        self.keychain = keychain
        self.useCase = useCase
        keychain.saveDeviceUUID()
    }
    
    // MARK: - 서버 이메일 중복/유효성 검사
    @MainActor
    func checkEmailAvailability() async {
        guard Validator.isValidEmailFormat(email) else {
            isEmailValidForUI = false
            return
        }
        isEmailValidForUI = true
        
        loginState = .loading
        
        do {
            try await useCase.checkEmailValidation(email)
            isEmailValidForUI = true
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
        
        guard isEmailValidForUI, isPasswordValid else {
            loginState = .failure("입력 정보를 확인해주세요.")
            return
        }
        
        guard !email.isEmpty, !password.isEmpty else {
            loginState = .failure("이메일과 비밀번호를 입력해주세요.")
            return
        }
        
        loginState = .loading
        
        guard let deviceToken = keychain.getDeviceUUID() else {
            loginState = .failure("디바이스 ID를 찾을 수 없습니다.")
            return
        }
        
        let request = SignUpRequest(
            email: email,
            password: password,
            nick: "anonymous",
            deviceToken: deviceToken
        )
        
        do {
            let response = try await useCase.signUp(request)
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
        
        let request = SignInEntity.Request(
            email: email,
            password: password,
            deviceToken: deviceId
        )
        
        do {
            let response = try await useCase.signIn(request)
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
            let request = try await manager.appleLogin()
            GTLogger.d("Apple 로그인 요청: \(request)")
            print(request)
            
            // deviceToken 가져오기
            guard keychain.getDeviceUUID() != nil else {
                loginState = .failure("디바이스 ID를 찾을 수 없습니다.")
                return
            }
            
            // 서버에 로그인 요청
            let response = try await useCase.signInApple(request)
            GTLogger.i("accessToken: \(response.accessToken)")
            keychain.saveAccessToken(response.accessToken)
            keychain.saveRefreshToken(response.refreshToken)
            loginState = .success
        } catch {
            loginState = .failure("Apple 로그인 실패: \(error.localizedDescription)")
            print("Apple 로그인 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 계정 생성 화면 이동 요청
    func navigateToCreateAccount() {
        print("회원가입 화면으로 이동 요청 (ViewModel)")
    }
}

//MARK: Extension - 로컬
extension LoginViewModel {
    // MARK: - 실시간 유효성 검사
    @MainActor
    func validateInputs() {
        isEmailValidForUI = email.isEmpty ? true : Validator.isValidEmailFormat(email)
        isPasswordValid = password.isEmpty ? true : Validator.validatePasswordFormat(password)
    }
}
