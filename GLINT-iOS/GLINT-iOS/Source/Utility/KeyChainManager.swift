//
//  KeyChainManager.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI

enum KeychainKey: String, CaseIterable {
    case deviceId
    case accessToken
    case refreshToken
    case appleAuthorizationCode
    
    var account: String { rawValue }
}

final class KeychainManager: Sendable {
    static let shared = KeychainManager()
    
    private let service: String
    
    init(service: String = "GLINT") {
        self.service = service
    }
    
    /// 키체인 저장
    func save(_ data: String, key: KeychainKey) {
        guard let stringData = data.data(using: .utf8) else {
            GTLogger.shared.token(key, success: false, details: "문자열 변환 실패")
            return
        }
        saveData(stringData, key: key)
    }
    
    /// 키체인 불러오기
    func read(_ key: KeychainKey) -> String? {
        guard let data = readData(key) else {
            GTLogger.shared.token(key, success: false, details: "데이터 없음")
            return nil
        }
        
        if let string = String(data: data, encoding: .utf8) {
            GTLogger.shared.token(key, success: true, details: "읽기 성공")
            return string
        }
        
        GTLogger.shared.token(key, success: false, details: "문자열 변환 실패")
        return nil
    }
    
    /// 키체인 삭제
    func delete(_ key: KeychainKey) {
        let query = createBaseQuery(for: key)
        let status = SecItemDelete(query as CFDictionary)
        
        switch status {
        case errSecSuccess:
            GTLogger.shared.token(key, success: true, details: "삭제 성공")
        case errSecItemNotFound:
            GTLogger.shared.token(key, success: false, details: "항목을 찾을 수 없음")
        default:
            GTLogger.shared.token(key, success: false, details: "삭제 실패 (상태: \(status))")
        }
    }
}

//MARK: Keychain 내부 함수
extension KeychainManager {
    
    
    private func createBaseQuery(for key: KeychainKey) -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.account
        ]
    }
    
    /// 키체인 저장 헬퍼
    private func saveData(_ data: Data, key: KeychainKey) {
        // 기존 항목이 있으면 업데이트, 없으면 생성
        if readData(key) != nil {
            updateData(data, key: key)
        } else {
            createData(data, key: key)
        }
    }
    
    /// 키체인 데이터 생성
    private func createData(_ data: Data, key: KeychainKey) {
        var query = createBaseQuery(for: key)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            GTLogger.shared.token(key, success: true, details: "생성 성공")
        } else {
            GTLogger.shared.token(key, success: false, details: "생성 실패 (상태: \(status))")
        }
    }
    
    /// 키체인 데이터 업데이트
    private func updateData(_ data: Data, key: KeychainKey) {
        let query = createBaseQuery(for: key)
        let attributes: [String: Any] = [kSecValueData as String: data]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        if status == errSecSuccess {
            GTLogger.shared.token(key, success: true, details: "업데이트 성공")
        } else {
            GTLogger.shared.token(key, success: false, details: "업데이트 실패 (상태: \(status))")
        }
    }
    
    /// 키체인 데이터 불러오기 (내부용)
    private func readData(_ key: KeychainKey) -> Data? {
        var query = createBaseQuery(for: key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            // 내부 메서드이므로 여기서는 로그하지 않음 (호출하는 곳에서 처리)
            return nil
        }
    }
}

//MARK: Keychain 편의 함수
extension KeychainManager {
    func saveAccessToken(_ token: String) {
        save(token, key: .accessToken)
    }
    
    func getAccessToken() -> String? {
        read(.accessToken)
    }
    
    func deleteAccessToken() {
        delete(.accessToken)
    }
    
    // Refresh Token 관련
    func saveRefreshToken(_ token: String) {
        save(token, key: .refreshToken)
    }
    
    func getRefreshToken() -> String? {
        read(.refreshToken)
    }
    
    func deleteRefreshToken() {
        delete(.refreshToken)
    }
    
    func saveAppleAuthorizationCode(_ code: String) {
        save(code, key: .appleAuthorizationCode)
    }
    
    func getAppleAuthorizationCode() -> String? {
        read(.appleAuthorizationCode)
    }
    
    // 모든 토큰 삭제
    func deleteAllTokens() {
        KeychainKey.allCases.forEach { key in
            delete(key)
        }
        GTLogger.shared.auth("모든 토큰 삭제 요청 완료")
    }
    
    // 디바이스 토큰 관련
    func saveDeviceUUID() {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        save(deviceId, key: .deviceId)
    }
    
    func getDeviceUUID() -> String? {
        read(.deviceId)
    }
    
    // 디바이스 UUID 자동 생성 및 반환
    func getOrCreateDeviceUUID() -> String {
        if let existingDeviceId = getDeviceUUID() {
            return existingDeviceId
        } else {
            let newDeviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
            saveDeviceUUID()
            return newDeviceId
        }
    }
}
