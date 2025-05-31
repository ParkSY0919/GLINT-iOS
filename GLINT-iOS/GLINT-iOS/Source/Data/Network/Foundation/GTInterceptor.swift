//
//  GTInterceptor.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/27/25.
//

import Foundation

import Alamofire

final class GTInterceptor: RequestInterceptor {
    enum InterceptorType {
        case `default`
        case nuke
    }
    
    private let type: InterceptorType
    private let keychain = KeychainManager.shared
    
    init(type: InterceptorType) {
        self.type = type
    }
    
    /// Request adapt
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var adaptedRequest = urlRequest
        
        if type == .nuke {
            adaptedRequest.setValue("\(Config.sesacKey)", forHTTPHeaderField: "SeSACKey")
        }
        if !shouldAddAuthHeader(for: urlRequest) {
            if let accessToken = keychain.getAccessToken() {
                adaptedRequest.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
        }
        completion(.success(adaptedRequest))
    }
    
    /// Request retry
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
                    // 토큰 갱신 성공 시 재시도
                    completion(.retry)
                case .failure:
                    // 토큰 갱신 실패. keychain all 삭제
                    self?.keychain.deleteAllTokens()
                    completion(.doNotRetryWithError(AuthError.tokenRefreshFailed))
                }
            }
        } else {
            completion(.doNotRetryWithError(error))
        }
    }
}

// MARK: - Private Methods
private extension GTInterceptor {
    /// 인증필요한 EndPoint인지 조회
    private func shouldAddAuthHeader(for request: URLRequest) -> Bool {
        // 인증이 필요하지 않은 엔드포인트
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
        
        return publicEndpoints.contains(path)
    }
    
    /// 리프레시 토큰 재발급
    private func refreshToken(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let refreshToken = keychain.getRefreshToken() else {
            completion(.failure(AuthError.noTokenFound))
            return
        }
        
        // Refresh Token API 호출
        // TODO: 
        let refreshRequest = RequestDTO.RefreshToken(refreshToken: refreshToken)
        let endpoint = AuthEndPoint.refreshToken(refreshRequest)
        
        AF.request(endpoint)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: ResponseDTO.RefreshToken.self) { [weak self] response in
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
