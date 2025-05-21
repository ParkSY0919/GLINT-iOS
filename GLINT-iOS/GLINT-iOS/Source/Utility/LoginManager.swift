//
//  LoginManager.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

protocol AuthService {
    func performAppleLogin(completion: @escaping (Result<(identityToken: String?, authCode: String?), Error>) -> Void)
}

final class AppleAuthService: NSObject, AuthService {
    func performAppleLogin(completion: @escaping (Result<(identityToken: String?, authCode: String?), Error>) -> Void) {
        let appleProvider = ASAuthorizationAppleIDProvider()
        let request = appleProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
        
        self.completion = completion
    }
    
    private var completion: ((Result<(identityToken: String?, authCode: String?), Error>) -> Void)?
}

extension AppleAuthService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            completion?(.failure(NSError(domain: "InvalidCredential", code: 0, userInfo: nil)))
            return
        }
        guard let userIdentifier = credential.identityToken,
              let code = credential.authorizationCode,
              let token = String(data: userIdentifier, encoding: .utf8),
              let authCode = String(data: code, encoding: .utf8) else {
            completion?(.failure(NSError(domain: "TokenConversionFailed", code: 0, userInfo: nil)))
            return
        }
        completion?(.success((token, authCode)))
        completion = nil
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion?(.failure(error))
        completion = nil
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.windows.first?.windowScene?.keyWindow ?? .init()
    }
}

final class TokenManager {
    static let shared = TokenManager()
    private let keyChain = KeyChainManager.shared
    
    func saveTokens(identityToken: String, authCode: String) -> Bool {
        let savedToken = keyChain.saveToken(identityToken)
        let savedAuthCode = keyChain.saveAuthCode(authCode)
        return savedToken && savedAuthCode
    }
}

import Foundation
import AuthenticationServices
final class LoginManager {
    static let shared = LoginManager()
    private let authService: AuthService
    private let tokenManager: TokenManager
    
    private init(authService: AuthService = AppleAuthService(),
                 tokenManager: TokenManager = .shared) {
        self.authService = authService
        self.tokenManager = tokenManager
    }
    
    func appleLogin(completion: @escaping (Result<(identityToken: String?, authCode: String?), Error>) -> Void) {
        authService.performAppleLogin { result in
            switch result {
            case .success(let (token, authCode)):
                if let token = token, let authCode = authCode,
                   self.tokenManager.saveTokens(identityToken: token, authCode: authCode) {
                    completion(.success((token, authCode)))
                } else {
                    completion(.failure(NSError(domain: "TokenSaveFailed", code: 0, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
