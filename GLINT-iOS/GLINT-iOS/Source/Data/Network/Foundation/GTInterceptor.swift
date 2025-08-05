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

// 요청 정보를 저장하는 구조체
private struct PendingRequest {
    let request: Request
    let session: Session
    let completion: (RetryResult) -> Void
    let originalToken: String?
}

final class GTInterceptor: RequestInterceptor {
    private let type: InterceptorType
    private let keychain = KeychainManager.shared
    
    // 토큰 갱신 관련 동기화
    private static let requestQueue = DispatchQueue(label: "GTInterceptor.requestQueue", attributes: .concurrent)
    private static var isRefreshing = false
    private static var pendingRequests: [PendingRequest] = []
    private static let refreshGroup = DispatchGroup()
    
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
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetry)
            return
        }
        
        let statusCode = response.statusCode
        
        // 토큰 관련 에러 처리
        if statusCode == 401 || statusCode == 403 || statusCode == 419 {
            handleTokenError(request: request, session: session, completion: completion)
        } else {
            completion(.doNotRetry)
        }
    }
    
    // MARK: - Private Methods
    
    private func handleTokenError(
        request: Request,
        session: Session,
        completion: @escaping (RetryResult) -> Void
    ) {
        let currentToken = keychain.getAccessToken()
        
        Self.requestQueue.async(flags: .barrier) {
            // 이미 토큰 갱신 중이면 대기 큐에 추가
            if Self.isRefreshing {
                let pendingRequest = PendingRequest(
                    request: request,
                    session: session,
                    completion: completion,
                    originalToken: currentToken
                )
                Self.pendingRequests.append(pendingRequest)
                GTLogger.shared.networkRequest("🔄 Request added to pending queue. Queue size: \(Self.pendingRequests.count)")
                return
            }
            
            // 토큰 갱신 시작
            Self.isRefreshing = true
            Self.refreshGroup.enter()
            
            DispatchQueue.main.async {
                self.performTokenRefresh { [weak self] result in
                    self?.handleRefreshResult(
                        result: result,
                        originalRequest: request,
                        originalCompletion: completion,
                        originalToken: currentToken
                    )
                }
            }
        }
    }
    
    private func handleRefreshResult(
        result: Result<Void, Error>,
        originalRequest: Request,
        originalCompletion: @escaping (RetryResult) -> Void,
        originalToken: String?
    ) {
        Self.requestQueue.async(flags: .barrier) {
            defer {
                Self.isRefreshing = false
                Self.refreshGroup.leave()
            }
            
            switch result {
            case .success:
                let newToken = self.keychain.getAccessToken()
                GTLogger.shared.networkSuccess("🔄 Token refresh successful. Processing \(Self.pendingRequests.count) pending requests")
                
                // 원본 요청 재시도
                originalCompletion(.retry)
                
                // 대기 중인 요청들 처리
                self.processPendingRequests(newToken: newToken)
                
            case .failure(let error):
                GTLogger.shared.networkFailure("❌ Token refresh failed", error: error)
                
                // 모든 요청 실패 처리 및 로그아웃
                self.handleRefreshFailure(
                    originalCompletion: originalCompletion,
                    error: error
                )
            }
        }
    }
    
    private func processPendingRequests(newToken: String?) {
        for pendingRequest in Self.pendingRequests {
            // 토큰 불일치 검사
            if let originalToken = pendingRequest.originalToken,
               let currentToken = newToken,
               originalToken != currentToken {
                
                // 토큰이 다르면 해당 요청은 새로운 토큰으로 재시도
                GTLogger.shared.networkRequest("🔄 Token mismatch detected. Retrying with new token")
                pendingRequest.completion(.retry)
            } else if pendingRequest.originalToken == nil && newToken != nil {
                // 원래 토큰이 없었지만 새로 생성된 경우
                pendingRequest.completion(.retry)
            } else {
                // 토큰 상태가 일치하지 않는 경우 - 보안상 로그아웃
                GTLogger.e("🚨 Token state inconsistency detected. Forcing logout")
                self.forceLogout()
                pendingRequest.completion(.doNotRetryWithError(AuthError.tokenRefreshFailed))
                return
            }
        }
        
        Self.pendingRequests.removeAll()
    }
    
    private func handleRefreshFailure(
        originalCompletion: @escaping (RetryResult) -> Void,
        error: Error
    ) {
        // 모든 대기 요청 실패 처리
        for pendingRequest in Self.pendingRequests {
            pendingRequest.completion(.doNotRetryWithError(AuthError.tokenRefreshFailed))
        }
        Self.pendingRequests.removeAll()
        
        // 원본 요청도 실패 처리
        originalCompletion(.doNotRetryWithError(AuthError.tokenRefreshFailed))
        
        // 로그아웃 처리
        forceLogout()
    }
    
    private func forceLogout() {
        GTLogger.e("🚨 Token state inconsistency detected. Forcing logout")
        keychain.deleteAllTokens()
        
        // 메인 스레드에서 로그아웃 처리
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .authTokenExpired, object: nil)
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
    
    private func performTokenRefresh(completion: @escaping (Result<Void, Error>) -> Void) {
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

// MARK: - Notification Names Extension
extension Notification.Name {
    static let authTokenExpired = Notification.Name("authTokenExpired")
}

