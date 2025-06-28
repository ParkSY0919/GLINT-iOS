//
//  GTInterceptor.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/27/25.
//

import Foundation

import Alamofire

enum InterceptorType {
    case `default`
    case multipart
    case nuke
    case refresh
}

final class GTInterceptor: RequestInterceptor {
    private let type: InterceptorType
    private let keychain = KeychainManager.shared
    
    init(type: InterceptorType) {
        self.type = type
    }
    
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var adaptedRequest = urlRequest
        adaptedRequest.setValue("\(Config.sesacKey)", forHTTPHeaderField: "SeSACKey")
        
        if !isPublicEndpoint(for: urlRequest) {
            if let accessToken = keychain.getAccessToken() {
                adaptedRequest.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            if type == .refresh {
                if let refreshToken = keychain.getRefreshToken() {
                    adaptedRequest.setValue("\(refreshToken)", forHTTPHeaderField: "RefreshToken")
                }
            }
        }
        completion(.success(adaptedRequest))
    }
    
    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        if let response = request.task?.response as? HTTPURLResponse {
            let statusCode = response.statusCode
            if statusCode == 401 || statusCode == 403 || statusCode == 419 {
                refreshToken { [weak self] result in
                    switch result {
                    case .success:
                        GTLogger.shared.networkSuccess("Token refresh successful")
                        completion(.retry)
                    case .failure(let refreshError):
                        GTLogger.shared.networkFailure("Token refresh failed", error: refreshError)
                        self?.keychain.deleteAllTokens()
                        completion(.doNotRetryWithError(AuthError.tokenRefreshFailed))
                    }
                }
            }
        }
    }
    
    /// accessToken 필요 없는 Path
    private func isPublicEndpoint(for request: URLRequest) -> Bool {
        let publicEndpoints = [
            "v1/users/login",
            "v1/users/join",
            "v1/users/validation/email",
            "v1/users/login/apple",
            "v1/users/login/kakao",
        ]
        
        guard let url = request.url else { return false }
        let path = url.pathComponents.dropFirst().joined(separator: "/")
        
        return publicEndpoints.contains(path)
    }
    
    private func refreshToken(completion: @escaping (Result<Void, Error>) -> Void) {
        let networkService = NetworkService<AuthEndPoint>()
        let endpoint = AuthEndPoint.refreshToken
        
        Task {
            do {
                let refreshResponse: RefreshTokenResponse = try await networkService.request(endpoint)
                
                // Keychain에 새로운 토큰 저장
                self.keychain.saveAccessToken(refreshResponse.accessToken)
                self.keychain.saveRefreshToken(refreshResponse.refreshToken)
                
                // 저장 성공 여부 확인
                if (self.keychain.getAccessToken() != nil) && (self.keychain.getRefreshToken() != nil) {
                    completion(.success(()))
                } else {
                    completion(.failure(AuthError.tokenSaveFailed))
                }
            } catch {
                GTLogger.shared.networkFailure("Refresh token logic failed", error: error)
                completion(.failure(error))
            }
        }
    }
}
