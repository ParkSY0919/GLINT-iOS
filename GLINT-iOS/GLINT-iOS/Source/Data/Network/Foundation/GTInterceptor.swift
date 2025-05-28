//
//  GTInterceptor.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/27/25.
//

import Foundation
import Alamofire

final class GTInterceptor: RequestInterceptor {
    private let keychain = KeychainProvider.shared
    private let refreshTokenEndpoint: String
    
    init(refreshTokenEndpoint: String = "v1/auth/refresh") {
        self.refreshTokenEndpoint = refreshTokenEndpoint
    }
    
    // MARK: - Request Adaptation
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var adaptedRequest = urlRequest
        
        // 토큰이 필요한 엔드포인트인지 확인
        if shouldAddAuthHeader(for: urlRequest) {
            if let accessToken = keychain.getAccessToken() {
                adaptedRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            adaptedRequest.setValue("SeSACKey", forHTTPHeaderField: Config.sesacKey)
        }
        
        completion(.success(adaptedRequest))
    }
    
    // MARK: - Request Retry
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        // 401 Unauthorized 에러인 경우 토큰 갱신 시도
        if response.statusCode == 401 {
            refreshToken { [weak self] result in
                switch result {
                case .success:
                    completion(.retry) // 토큰 갱신 성공 시 재시도
                case .failure:
                    // 토큰 갱신 실패 시 로그아웃 처리
                    self?.keychain.deleteAllTokens()
                    completion(.doNotRetryWithError(AuthError.tokenRefreshFailed))
                }
            }
        } else {
            completion(.doNotRetryWithError(error))
        }
    }
    
    // MARK: - Private Methods
    private func shouldAddAuthHeader(for request: URLRequest) -> Bool {
        // 인증이 필요하지 않은 엔드포인트들
        let publicEndpoints = [
            "v1/users/login",
            "v1/users/join",
            "v1/users/validation/email",
            "v1/users/login/apple",
            "v1/users/login/kakao",
            "v1/auth/refresh"
        ]
        
        guard let url = request.url else { return false }
        let path = url.pathComponents.dropFirst().joined(separator: "/")
        
        return !publicEndpoints.contains(path)
    }
    
    private func refreshToken(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let refreshToken = keychain.getRefreshToken() else {
            completion(.failure(AuthError.noTokenFound))
            return
        }
        
        // Refresh Token API 호출
        let refreshRequest = RefreshTokenRequest(refreshToken: refreshToken)
        let endpoint = AuthEndpoint.refreshToken(refreshRequest)
        
        AF.request(endpoint)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: RefreshTokenResponse.self) { [weak self] response in
                switch response.result {
                case .success(let refreshResponse):
                    // 새로운 토큰들을 KeychainProvider로 저장
                    self?.keychain.saveAccessToken(refreshResponse.accessToken)
                    self?.keychain.saveRefreshToken(refreshResponse.refreshToken)
                    
                    if (self?.keychain.getAccessToken() != nil) && (self?.keychain.getRefreshToken() != nil) {
                        completion(.success(()))
                    } else {
                        completion(.failure(AuthError.tokenSaveFailed))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case noTokenFound
    case tokenRefreshFailed
    case tokenSaveFailed
    
    var errorDescription: String? {
        switch self {
        case .noTokenFound: return "저장된 토큰이 없습니다."
        case .tokenRefreshFailed: return "토큰 갱신에 실패했습니다."
        case .tokenSaveFailed: return "토큰 저장에 실패했습니다."
        }
    }
}
