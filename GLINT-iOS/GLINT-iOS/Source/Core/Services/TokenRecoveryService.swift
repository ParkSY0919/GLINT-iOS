//
//  TokenRecoveryService.swift
//  GLINT-iOS
//
//  Created by Claude on 8/15/25.
//

import Foundation
import Network

/// 토큰 관련 오류 발생 시 다양한 복구 시나리오를 제공하는 서비스
final class TokenRecoveryService {
    static let shared = TokenRecoveryService()
    
    private let keychain = KeychainManager.shared
    private let temporaryStorage = TemporaryTokenStorage.shared
    private let networkMonitor = NWPathMonitor()
    private let recoveryQueue = DispatchQueue(label: "TokenRecoveryService", qos: .userInitiated)
    
    // 복구 시도 히스토리
    private var recoveryAttempts: [RecoveryAttempt] = []
    private let maxRecoveryAttempts = 3
    private let recoveryTimeWindow: TimeInterval = 300 // 5분
    
    private init() {
        startNetworkMonitoring()
    }
    
    deinit {
        networkMonitor.cancel()
    }
}

// MARK: - 복구 시나리오 타입 정의
extension TokenRecoveryService {
    
    enum RecoveryScenario {
        case immediateRetry                    // 즉시 재시도
        case waitAndRetry(delay: TimeInterval) // 지연 후 재시도
        case temporaryStorage                  // 임시 저장소 활용
        case keychainReset                    // 키체인 초기화 후 재로그인
        case networkAwareRecovery             // 네트워크 상태 기반 복구
        case gracefulDegradation              // 기능 제한 모드
        case forceReauthentication           // 강제 재인증
        case systemLevelRecovery             // 시스템 레벨 복구
    }
    
    enum RecoveryResult {
        case success(scenario: RecoveryScenario)
        case failure(reason: String)
        case partial(achievedScenario: RecoveryScenario, remainingIssues: [String])
        case requiresUserAction(message: String, action: String)
    }
    
    struct RecoveryAttempt {
        let timestamp: Date
        let error: AuthError
        let scenario: RecoveryScenario
        let result: RecoveryResult
    }
}

// MARK: - 주요 복구 메소드
extension TokenRecoveryService {
    
    /// 에러에 따른 최적 복구 시나리오 결정 및 실행
    func attemptRecovery(for error: AuthError, context: String = "general") async -> RecoveryResult {
        GTLogger.shared.auth("🔧 토큰 복구 시도 시작 - 에러: \(error), 컨텍스트: \(context)")
        
        // 최근 복구 시도 횟수 확인
        if hasExceededRecoveryLimit(for: error) {
            GTLogger.e("❌ 복구 시도 한도 초과")
            return .requiresUserAction(
                message: "복구를 여러 번 시도했지만 실패했습니다. 앱을 재시작해주세요.",
                action: "앱 재시작"
            )
        }
        
        // 에러별 복구 시나리오 결정
        let scenario = determineRecoveryScenario(for: error, context: context)
        GTLogger.shared.auth("📋 선택된 복구 시나리오: \(scenario)")
        
        // 복구 실행
        let result = await executeRecoveryScenario(scenario, for: error)
        
        // 결과 기록
        recordRecoveryAttempt(error: error, scenario: scenario, result: result)
        
        return result
    }
    
    /// 에러별 최적 복구 시나리오 결정
    private func determineRecoveryScenario(for error: AuthError, context: String) -> RecoveryScenario {
        switch error {
        case .tokenRefreshFailed:
            return determineNetworkBasedScenario()
            
        case .tokenSaveFailed, .keychainStorageCorrupted:
            return .temporaryStorage
            
        case .keychainAccessDenied:
            if context == "background" {
                return .gracefulDegradation
            } else {
                return .systemLevelRecovery
            }
            
        case .deviceStorageFull:
            return .systemLevelRecovery
            
        case .tokenStateInconsistent, .tokenMismatch:
            return .keychainReset
            
        case .tokenValidationFailed:
            return .waitAndRetry(delay: 2.0)
            
        case .multipleRefreshAttempts:
            return .waitAndRetry(delay: 5.0)
            
        case .tokenContentInvalid, .tokenLengthMismatch:
            return .forceReauthentication
            
        default:
            return .immediateRetry
        }
    }
    
    /// 네트워크 상태 기반 시나리오 결정
    private func determineNetworkBasedScenario() -> RecoveryScenario {
        return recoveryQueue.sync {
            let currentPath = networkMonitor.currentPath
            
            if currentPath.status == .satisfied {
                if currentPath.isExpensive {
                    // 셀룰러 네트워크 - 지연 후 재시도
                    return .waitAndRetry(delay: 3.0)
                } else {
                    // WiFi - 즉시 재시도
                    return .immediateRetry
                }
            } else {
                // 네트워크 없음 - 네트워크 복구 대기
                return .networkAwareRecovery
            }
        }
    }
    
    /// 복구 시나리오 실행
    private func executeRecoveryScenario(_ scenario: RecoveryScenario, for error: AuthError) async -> RecoveryResult {
        switch scenario {
        case .immediateRetry:
            return await executeImmediateRetry()
            
        case .waitAndRetry(let delay):
            return await executeDelayedRetry(delay: delay)
            
        case .temporaryStorage:
            return await executeTemporaryStorageRecovery()
            
        case .keychainReset:
            return await executeKeychainReset()
            
        case .networkAwareRecovery:
            return await executeNetworkAwareRecovery()
            
        case .gracefulDegradation:
            return await executeGracefulDegradation()
            
        case .forceReauthentication:
            return await executeForceReauthentication()
            
        case .systemLevelRecovery:
            return await executeSystemLevelRecovery(for: error)
        }
    }
}

// MARK: - 개별 복구 시나리오 구현
extension TokenRecoveryService {
    
    /// 즉시 재시도
    private func executeImmediateRetry() async -> RecoveryResult {
        GTLogger.shared.auth("⚡ 즉시 재시도 실행")
        
        do {
            try keychain.validateTokenState()
            return .success(scenario: .immediateRetry)
        } catch {
            return .failure(reason: "즉시 재시도 실패: \(error.localizedDescription)")
        }
    }
    
    /// 지연 후 재시도
    private func executeDelayedRetry(delay: TimeInterval) async -> RecoveryResult {
        GTLogger.shared.auth("⏱️ \(delay)초 지연 후 재시도")
        
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        return await executeImmediateRetry()
    }
    
    /// 임시 저장소 복구
    private func executeTemporaryStorageRecovery() async -> RecoveryResult {
        GTLogger.shared.auth("💾 임시 저장소 복구 시도")
        
        // 현재 토큰을 임시 저장소에 백업
        let currentAccess = keychain.getAccessToken()
        let currentRefresh = keychain.getRefreshToken()
        
        if currentAccess != nil || currentRefresh != nil {
            temporaryStorage.store(accessToken: currentAccess, refreshToken: currentRefresh)
        }
        
        // 임시 저장소에서 키체인 복구 시도
        if temporaryStorage.hasValidTokens() {
            let recoverySuccess = temporaryStorage.attemptKeychainRecovery(with: keychain)
            
            if recoverySuccess {
                return .success(scenario: .temporaryStorage)
            } else {
                return .partial(
                    achievedScenario: .temporaryStorage,
                    remainingIssues: ["키체인 복구 실패, 임시 저장소 활성화됨"]
                )
            }
        }
        
        return .failure(reason: "임시 저장소에 유효한 토큰이 없음")
    }
    
    /// 키체인 초기화 후 재로그인
    private func executeKeychainReset() async -> RecoveryResult {
        GTLogger.shared.auth("🔄 키체인 초기화 실행")
        
        // 기존 토큰 백업 (임시 저장소)
        let currentAccess = keychain.getAccessToken()
        let currentRefresh = keychain.getRefreshToken()
        
        if currentAccess != nil || currentRefresh != nil {
            temporaryStorage.store(accessToken: currentAccess, refreshToken: currentRefresh)
        }
        
        // 키체인 초기화
        keychain.deleteAllTokens()
        
        // 키체인 상태 재검증
        let diagnosis = keychain.diagnoseKeychainHealth()
        GTLogger.shared.auth("🔍 키체인 초기화 후 진단: \(diagnosis)")
        
        return .requiresUserAction(
            message: "보안을 위해 다시 로그인해주세요.",
            action: "로그인하기"
        )
    }
    
    /// 네트워크 인식 복구
    private func executeNetworkAwareRecovery() async -> RecoveryResult {
        GTLogger.shared.auth("🌐 네트워크 인식 복구 시작")
        
        return await withCheckedContinuation { continuation in
            networkMonitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    GTLogger.shared.auth("✅ 네트워크 연결 복구됨")
                    continuation.resume(returning: .success(scenario: .networkAwareRecovery))
                }
            }
            
            // 10초 타임아웃
            DispatchQueue.global().asyncAfter(deadline: .now() + 10.0) {
                continuation.resume(returning: .failure(reason: "네트워크 복구 타임아웃"))
            }
        }
    }
    
    /// 기능 제한 모드
    private func executeGracefulDegradation() async -> RecoveryResult {
        GTLogger.shared.auth("⚠️ 기능 제한 모드 활성화")
        
        // 오프라인 데이터나 캐시된 정보 활용
        // 핵심 기능만 제공하고 나머지는 제한
        
        return .partial(
            achievedScenario: .gracefulDegradation,
            remainingIssues: ["일부 기능이 제한됩니다"]
        )
    }
    
    /// 강제 재인증
    private func executeForceReauthentication() async -> RecoveryResult {
        GTLogger.shared.auth("🔐 강제 재인증 실행")
        
        // 모든 토큰 삭제
        keychain.deleteAllTokens()
        temporaryStorage.clear()
        
        // 사용자에게 재로그인 요청
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .authTokenExpired, object: nil)
        }
        
        return .requiresUserAction(
            message: "보안을 위해 다시 로그인이 필요합니다.",
            action: "로그인하기"
        )
    }
    
    /// 시스템 레벨 복구
    private func executeSystemLevelRecovery(for error: AuthError) async -> RecoveryResult {
        GTLogger.shared.auth("🔧 시스템 레벨 복구 시작")
        
        var issues: [String] = []
        var recoveryActions: [String] = []
        
        // 디바이스 상태 확인 및 복구 제안
        switch error {
        case .deviceStorageFull:
            issues.append("저장공간 부족")
            recoveryActions.append("불필요한 파일 삭제")
            
        case .keychainAccessDenied:
            issues.append("키체인 접근 거부")
            recoveryActions.append("디바이스 잠금 해제")
            recoveryActions.append("Face ID/Touch ID 설정 확인")
            
        default:
            issues.append("시스템 레벨 문제")
            recoveryActions.append("디바이스 재부팅")
            recoveryActions.append("iOS 업데이트 확인")
        }
        
        return .requiresUserAction(
            message: "시스템 문제가 감지되었습니다.\n\(recoveryActions.joined(separator: "\n"))",
            action: "설정으로 이동"
        )
    }
}

// MARK: - 보조 메소드
extension TokenRecoveryService {
    
    /// 네트워크 모니터링 시작
    private func startNetworkMonitoring() {
        networkMonitor.start(queue: recoveryQueue)
    }
    
    /// 복구 시도 횟수 제한 확인
    private func hasExceededRecoveryLimit(for error: AuthError) -> Bool {
        let recentAttempts = recoveryAttempts.filter { attempt in
            Date().timeIntervalSince(attempt.timestamp) < recoveryTimeWindow &&
            type(of: attempt.error) == type(of: error)
        }
        
        return recentAttempts.count >= maxRecoveryAttempts
    }
    
    /// 복구 시도 기록
    private func recordRecoveryAttempt(error: AuthError, scenario: RecoveryScenario, result: RecoveryResult) {
        let attempt = RecoveryAttempt(
            timestamp: Date(),
            error: error,
            scenario: scenario,
            result: result
        )
        
        recoveryAttempts.append(attempt)
        
        // 오래된 기록 정리 (최대 100개 유지)
        if recoveryAttempts.count > 100 {
            recoveryAttempts.removeFirst(recoveryAttempts.count - 100)
        }
        
        GTLogger.shared.auth("📊 복구 시도 기록됨: \(scenario) -> \(result)")
    }
    
    /// 복구 통계 조회
    func getRecoveryStatistics() -> [String: Any] {
        let recentAttempts = recoveryAttempts.filter { attempt in
            Date().timeIntervalSince(attempt.timestamp) < recoveryTimeWindow
        }
        
        let successCount = recentAttempts.filter { attempt in
            if case .success = attempt.result { return true }
            return false
        }.count
        
        let totalCount = recentAttempts.count
        let successRate = totalCount > 0 ? Double(successCount) / Double(totalCount) : 0.0
        
        return [
            "totalAttempts": totalCount,
            "successfulAttempts": successCount,
            "successRate": successRate,
            "timeWindow": recoveryTimeWindow,
            "recentAttempts": recentAttempts.map { attempt in
                [
                    "timestamp": attempt.timestamp,
                    "error": String(describing: attempt.error),
                    "scenario": String(describing: attempt.scenario),
                    "result": String(describing: attempt.result)
                ]
            }
        ]
    }
}