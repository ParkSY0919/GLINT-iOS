//
//  LoginManager.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import Foundation
import AuthenticationServices

final class LoginManager: NSObject {
    private var continuation: CheckedContinuation<SocialLoginResponse, Error>?
        
    func appleLogin() async throws -> SocialLoginResponse {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.continuation = continuation
            self?.requestAppleLogin()
        }
    }
}

extension LoginManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func requestAppleLogin() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = []
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.keyWindow
        else { return UIWindow() }
        
        return window
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let idToken = appleIDCredential.identityToken,
            let authorizationCode = appleIDCredential.authorizationCode,
            let idTokenString = String(data: idToken, encoding: .utf8),
            let authorizationCodeString = String(data: authorizationCode, encoding: .utf8)
        else { return }
    
        print("🍎 [appleLogin] token: \(idTokenString)")
        print("🍎 [appleLogin] authorizationCode: \(authorizationCodeString)")
        let nick = appleIDCredential.fullName?.givenName ?? "anonymous"
        
        continuation?.resume(returning: SocialLoginResponse(
            idToken: idTokenString,
            authorizationCode: authorizationCodeString,
            nick: nick
        ))
        continuation = nil
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
