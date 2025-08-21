//
//  TemporaryTokenStorage.swift
//  GLINT-iOS
//
//  Created by Claude on 8/15/25.
//

import Foundation

/// 키체인 저장 실패 시 임시로 메모리에 토큰을 저장하는 클래스
/// 앱이 종료되면 데이터가 사라지므로 보안상 안전하며, 일시적인 키체인 문제 대응용
final class TemporaryTokenStorage: Sendable {
    static let shared = TemporaryTokenStorage()
    
    private let queue = DispatchQueue(label: "TemporaryTokenStorage", attributes: .concurrent)
    private var _accessToken: String?
    private var _refreshToken: String?
    private var _storedAt: Date?
    
    // 임시 저장 유효 시간 (30분)
    private let validityDuration: TimeInterval = 30 * 60
    
    private init() {}
    
    /// 토큰 임시 저장
    func store(accessToken: String?, refreshToken: String?) {
        queue.async(flags: .barrier) {
            self._accessToken = accessToken
            self._refreshToken = refreshToken
            self._storedAt = Date()
            
            GTLogger.shared.auth("📦 토큰 임시 저장 완료 (유효시간: \(Int(self.validityDuration/60))분)")
        }
    }
    
    /// 저장된 토큰 조회
    func getAccessToken() -> String? {
        return queue.sync {
            guard isValid() else {
                clearExpiredTokens()
                return nil
            }
            return _accessToken
        }
    }
    
    /// 저장된 리프레시 토큰 조회
    func getRefreshToken() -> String? {
        return queue.sync {
            guard isValid() else {
                clearExpiredTokens()
                return nil
            }
            return _refreshToken
        }
    }
    
    /// 임시 저장된 토큰이 있는지 확인
    func hasValidTokens() -> Bool {
        return queue.sync {
            return isValid() && _accessToken != nil && _refreshToken != nil
        }
    }
    
    /// 임시 저장소 클리어
    func clear() {
        queue.async(flags: .barrier) {
            self._accessToken = nil
            self._refreshToken = nil
            self._storedAt = nil
            
            GTLogger.shared.auth("🗑️ 임시 토큰 저장소 클리어")
        }
    }
    
    /// 키체인 복구 시도 (임시 저장된 토큰을 키체인에 다시 저장)
    func attemptKeychainRecovery(with keychain: KeychainManager) -> Bool {
        return queue.sync {
            guard let accessToken = _accessToken,
                  let refreshToken = _refreshToken,
                  isValid() else {
                return false
            }
            
            do {
                try keychain.saveTokenWithValidation(accessToken, key: .accessToken)
                try keychain.saveTokenWithValidation(refreshToken, key: .refreshToken)
                
                GTLogger.shared.auth("✅ 키체인 복구 성공 - 임시 저장소 클리어")
                
                // 복구 성공 시 임시 저장소 클리어
                self._accessToken = nil
                self._refreshToken = nil
                self._storedAt = nil
                
                return true
            } catch {
                GTLogger.e("❌ 키체인 복구 실패: \(error)")
                return false
            }
        }
    }
    
    /// 저장된 토큰의 유효성 확인
    private func isValid() -> Bool {
        guard let storedAt = _storedAt else { return false }
        return Date().timeIntervalSince(storedAt) < validityDuration
    }
    
    /// 만료된 토큰 클리어
    private func clearExpiredTokens() {
        _accessToken = nil
        _refreshToken = nil
        _storedAt = nil
        
        GTLogger.shared.auth("⏰ 만료된 임시 토큰 클리어")
    }
    
    /// 현재 상태 진단
    func getDiagnosticInfo() -> [String: Any] {
        return queue.sync {
            var info: [String: Any] = [:]
            info["hasAccessToken"] = _accessToken != nil
            info["hasRefreshToken"] = _refreshToken != nil
            info["storedAt"] = _storedAt?.description ?? "nil"
            info["isValid"] = isValid()
            
            if let storedAt = _storedAt {
                let timeElapsed = Date().timeIntervalSince(storedAt)
                let timeRemaining = validityDuration - timeElapsed
                info["timeElapsed"] = timeElapsed
                info["timeRemaining"] = max(0, timeRemaining)
            }
            
            return info
        }
    }
}