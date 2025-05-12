//
//  LoginManager.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import Foundation
import AuthenticationServices

final class LoginManager: NSObject {
    static let shared = LoginManager()
    
    private override init() {}
    
    func appleLogin() {
        let appleProvider = ASAuthorizationAppleIDProvider()
        let request = appleProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
}

extension LoginManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        loginWithApple(userInfo: credential)
    }
    
    func loginWithApple(userInfo: ASAuthorizationAppleIDCredential) {
        guard let userIdentifier = userInfo.identityToken,
              let code = userInfo.authorizationCode,
              let token = String(data: userIdentifier, encoding: .utf8),
              let authCode = String(data: code, encoding: .utf8) else {
            return
        }
        
        // KeyChain에 저장 (보안 강화를 위해)
        KeyChainManager.shared.saveToken(token) //idToken
        KeyChainManager.shared.saveAuthCode(authCode) //deviceToken
        print("token: \(token)")
        print("authCode: \(authCode)")
        // 상태 업데이트 (예시)
        // self.socialType = .apple
        // self.setToken(token: token)
        // self.setUserInfo(userInfo: userInfo)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple 로그인 에러: \(error.localizedDescription)")
    }
}

