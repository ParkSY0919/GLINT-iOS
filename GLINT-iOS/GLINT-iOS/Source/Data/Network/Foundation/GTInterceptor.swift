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

// 토큰 검증 결과 타입
private enum TokenValidationResult {
    case valid
    case inconsistent(String)
    case recoverable(String)
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
        // 강화된 토큰 상태 검증
        let tokenValidationResult = validateTokenStateConsistency(newToken: newToken)
        
        switch tokenValidationResult {
        case .valid:
            // 정상 상태 - 요청들 처리
            processPendingRequestsWithValidatedTokens(newToken: newToken)
            
        case .inconsistent(let reason):
            // 불일치 감지 - 강제 로그아웃
            GTLogger.e("🚨 토큰 상태 불일치 감지: \(reason)")
            handleTokenInconsistency(reason: reason)
            
        case .recoverable(let issue):
            // 복구 가능한 문제 - 복구 시도 후 재처리
            GTLogger.shared.networkRequest("⚠️ 복구 가능한 토큰 문제: \(issue)")
            if attemptTokenStateRecovery() {
                processPendingRequestsWithValidatedTokens(newToken: keychain.getAccessToken())
            } else {
                handleTokenInconsistency(reason: "복구 실패: \(issue)")
            }
        }
    }
    
    /// 토큰 상태 일관성 검증
    private func validateTokenStateConsistency(newToken: String?) -> TokenValidationResult {
        // 1. 기본 토큰 존재 여부 확인
        let storedAccessToken = keychain.getAccessToken()
        let storedRefreshToken = keychain.getRefreshToken()
        
        // 2. 토큰 쌍 일관성 확인
        if (storedAccessToken == nil) != (storedRefreshToken == nil) {
            return .inconsistent("토큰 쌍 불일치: access=\(storedAccessToken != nil), refresh=\(storedRefreshToken != nil)")
        }
        
        // 3. 새 토큰과 저장된 토큰 비교
        if let newToken = newToken, let storedToken = storedAccessToken {
            if newToken != storedToken {
                return .inconsistent("새 토큰과 저장된 토큰 불일치")
            }
        }
        
        // 4. 대기 중인 요청들의 토큰 상태 확인
        let inconsistentRequests = Self.pendingRequests.filter { request in
            if let originalToken = request.originalToken,
               let currentToken = storedAccessToken {
                return originalToken != currentToken && !isTokenRefreshScenario(original: originalToken, current: currentToken)
            }
            return false
        }
        
        if !inconsistentRequests.isEmpty {
            return .recoverable("대기 요청 중 토큰 불일치 발견 (\(inconsistentRequests.count)건)")
        }
        
        // 5. 토큰 내용 유효성 재검증
        do {
            if let accessToken = storedAccessToken {
                try keychain.validateTokenContent(accessToken, for: .accessToken)
            }
            if let refreshToken = storedRefreshToken {
                try keychain.validateTokenContent(refreshToken, for: .refreshToken)
            }
        } catch {
            return .inconsistent("토큰 내용 검증 실패: \(error.localizedDescription)")
        }
        
        return .valid
    }
    
    /// 정상 검증된 토큰으로 대기 요청들 처리
    private func processPendingRequestsWithValidatedTokens(newToken: String?) {
        for pendingRequest in Self.pendingRequests {
            let shouldRetry = determineShouldRetry(for: pendingRequest, newToken: newToken)
            
            if shouldRetry {
                GTLogger.shared.networkRequest("🔄 토큰 갱신 완료 - 요청 재시도")
                pendingRequest.completion(.retry)
            } else {
                GTLogger.shared.networkRequest("⏭️ 요청 스킵 - 토큰 상태 불일치")
                pendingRequest.completion(.doNotRetryWithError(AuthError.tokenMismatch))
            }
        }
        
        Self.pendingRequests.removeAll()
    }
    
    /// 요청 재시도 여부 판단
    private func determineShouldRetry(for request: PendingRequest, newToken: String?) -> Bool {
        guard let newToken = newToken else { return false }
        
        // 원본 토큰이 없는 경우 (최초 요청)
        if request.originalToken == nil {
            return true
        }
        
        // 토큰 갱신 시나리오인지 확인
        if let originalToken = request.originalToken {
            return isTokenRefreshScenario(original: originalToken, current: newToken)
        }
        
        return false
    }
    
    /// 정상적인 토큰 갱신 시나리오인지 판단
    private func isTokenRefreshScenario(original: String, current: String) -> Bool {
        // 토큰 길이 비교 (일반적으로 갱신된 토큰은 비슷한 길이)
        let lengthDifference = abs(original.count - current.count)
        if lengthDifference > 100 { // 100자 이상 차이나면 의심스러움
            return false
        }
        
        // JWT 토큰인 경우 구조 확인
        let originalParts = original.components(separatedBy: ".")
        let currentParts = current.components(separatedBy: ".")
        
        if originalParts.count == 3 && currentParts.count == 3 {
            // JWT 헤더는 보통 동일해야 함
            if originalParts[0] != currentParts[0] {
                GTLogger.shared.networkRequest("⚠️ JWT 헤더 불일치 감지")
                return false
            }
        }
        
        return true
    }
    
    /// 토큰 상태 불일치 처리
    private func handleTokenInconsistency(reason: String) {
        GTLogger.e("🚨 토큰 불일치 처리 시작: \(reason)")
        
        // 모든 대기 요청 실패 처리
        for pendingRequest in Self.pendingRequests {
            pendingRequest.completion(.doNotRetryWithError(AuthError.tokenStateInconsistent))
        }
        Self.pendingRequests.removeAll()
        
        // 키체인 상태 진단
        let diagnosis = keychain.diagnoseKeychainHealth()
        GTLogger.e("🔍 키체인 진단 결과: \(diagnosis)")
        
        // 강제 로그아웃
        forceLogout()
    }
    
    /// 토큰 상태 복구 시도
    private func attemptTokenStateRecovery() -> Bool {
        GTLogger.shared.networkRequest("🔧 토큰 상태 복구 시도")
        
        // 1. 키체인 상태 검증
        do {
            try keychain.validateTokenState()
            GTLogger.shared.networkSuccess("✅ 키체인 상태 검증 통과")
            return true
        } catch {
            GTLogger.shared.networkFailure("❌ 키체인 상태 검증 실패", error: error)
        }
        
        // 2. 임시 저장소에서 복구 시도
        if TemporaryTokenStorage.shared.hasValidTokens() {
            let recoverySuccess = TemporaryTokenStorage.shared.attemptKeychainRecovery(with: keychain)
            if recoverySuccess {
                GTLogger.shared.networkSuccess("✅ 임시 저장소에서 복구 성공")
                return true
            }
        }
        
        // 3. 토큰 무결성 재검증
        if let accessToken = keychain.getAccessToken(),
           let refreshToken = keychain.getRefreshToken() {
            do {
                try keychain.verifyKeychainIntegrity(for: .accessToken, expectedToken: accessToken)
                try keychain.verifyKeychainIntegrity(for: .refreshToken, expectedToken: refreshToken)
                GTLogger.shared.networkSuccess("✅ 토큰 무결성 재검증 통과")
                return true
            } catch {
                GTLogger.shared.networkFailure("❌ 토큰 무결성 재검증 실패", error: error)
            }
        }
        
        GTLogger.shared.d("❌ 모든 복구 시도 실패")
        return false
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
                
                // 향상된 토큰 저장 및 검증 프로세스
                try await self.saveTokensWithEnhancedValidation(
                    accessToken: refreshResponse.accessToken,
                    refreshToken: refreshResponse.refreshToken
                )
                
                completion(.success(()))
                
            } catch {
                GTLogger.shared.networkFailure("Refresh token logic failed", error: error)
                completion(.failure(error))
            }
        }
    }
    
    /// 향상된 토큰 저장 및 검증 프로세스
    @MainActor
    private func saveTokensWithEnhancedValidation(accessToken: String, refreshToken: String) async throws {
        GTLogger.shared.networkRequest("🔐 강화된 토큰 저장 프로세스 시작")
        
        // 1단계: 토큰 사전 검증
        do {
            try await Task.detached {
                try self.keychain.validateTokenContent(accessToken, for: .accessToken)
                try self.keychain.validateTokenContent(refreshToken, for: .refreshToken)
            }.value
            
            GTLogger.shared.networkSuccess("✅ 토큰 사전 검증 통과")
        } catch {
            GTLogger.shared.networkFailure("❌ 토큰 사전 검증 실패", error: error)
            throw error
        }
        
        // 2단계: 기존 토큰 상태 백업
        let originalAccessToken = keychain.getAccessToken()
        let originalRefreshToken = keychain.getRefreshToken()
        
        // 3단계: 토큰 저장 시도
        do {
            try await Task.detached {
                try self.keychain.saveTokenWithValidation(accessToken, key: .accessToken)
                try self.keychain.saveTokenWithValidation(refreshToken, key: .refreshToken)
            }.value
            
            GTLogger.shared.networkSuccess("✅ 토큰 저장 및 검증 완료")
        } catch {
            GTLogger.shared.networkFailure("❌ 토큰 저장 검증 실패", error: error)
            
            // 4단계: 실패 시 복구 시도
            try await self.attemptTokenRecovery(
                originalAccessToken: originalAccessToken,
                originalRefreshToken: originalRefreshToken,
                error: error
            )
            
            throw error
        }
        
        // 5단계: 최종 토큰 상태 검증
        do {
            try await Task.detached {
                try self.keychain.validateTokenState()
            }.value
            
            GTLogger.shared.networkSuccess("✅ 최종 토큰 상태 검증 완료")
        } catch {
            GTLogger.shared.networkFailure("❌ 최종 토큰 상태 검증 실패", error: error)
            
            // 심각한 상태 불일치 - 강제 로그아웃
            self.forceLogout()
            throw AuthError.tokenStateInconsistent
        }
        
        // 6단계: 키체인 건강성 진단 (선택적)
        let healthDiagnosis = keychain.diagnoseKeychainHealth()
        GTLogger.shared.networkRequest("📊 키체인 건강성 진단: \(healthDiagnosis)")
    }
    
    /// 토큰 복구 시도
    @MainActor
    private func attemptTokenRecovery(
        originalAccessToken: String?,
        originalRefreshToken: String?,
        error: Error
    ) async throws {
        GTLogger.shared.networkRequest("🔄 토큰 복구 시도 시작")
        
        // 에러 유형별 복구 전략
        switch error {
        case AuthError.tokenStateInconsistent, AuthError.keychainStorageCorrupted:
            // 심각한 상태 불일치 - 모든 토큰 삭제 후 강제 로그아웃
            GTLogger.e("🚨 심각한 토큰 상태 불일치 감지 - 강제 로그아웃")
            keychain.deleteAllTokens()
            throw error
            
        case AuthError.tokenValidationFailed, AuthError.tokenContentInvalid:
            // 토큰 내용 문제 - 원본 복구 시도
            if let original = originalAccessToken {
                keychain.saveAccessToken(original)
            }
            if let original = originalRefreshToken {
                keychain.saveRefreshToken(original)
            }
            GTLogger.shared.networkRequest("🔄 원본 토큰 복구 완료")
            
        case AuthError.keychainAccessDenied, AuthError.deviceStorageFull:
            // 시스템 레벨 문제 - 사용자에게 안내 후 재시도 대기
            GTLogger.e("⚠️ 시스템 레벨 저장 문제 감지")
            
            // 메모리에 임시 저장 (앱 종료 전까지 사용)
            TemporaryTokenStorage.shared.store(
                accessToken: keychain.getAccessToken(),
                refreshToken: keychain.getRefreshToken()
            )
            
            throw error
            
        default:
            // 기타 에러 - 기본 복구 시도
            GTLogger.shared.networkRequest("🔄 기본 복구 프로세스 실행")
            throw error
        }
    }
}

// MARK: - Notification Names Extension
extension Notification.Name {
    static let authTokenExpired = Notification.Name("authTokenExpired")
}

