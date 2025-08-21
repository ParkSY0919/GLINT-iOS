//
//  KeyChainManager.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/12/25.
//

import SwiftUI
import Darwin

enum KeychainKey: String, CaseIterable {
    case deviceId
    case userId
    case nickname
    case accessToken
    case refreshToken
    case appleAuthorizationCode
    case fcmToken
    
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
//            GTLogger.shared.token(key, success: true, details: "읽기 성공")
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
            let errorInfo = analyzeKeychainError(status, operation: "create", key: key)
            GTLogger.shared.token(key, success: false, details: errorInfo)
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
            let errorInfo = analyzeKeychainError(status, operation: "update", key: key)
            GTLogger.shared.token(key, success: false, details: errorInfo)
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
    func saveUserId(_ userId: String) {
        save(userId, key: .userId)
    }
    
    func getUserId() -> String? {
        read(.userId)
    }
    
    func saveNickname(_ nickname: String) {
        save(nickname, key: .nickname)
    }
    
    func getNickname() -> String? {
        read(.nickname)
    }
    
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
    
    // FCM 토큰 관련
    func saveFCMToken(_ token: String) {
        save(token, key: .fcmToken)
        GTLogger.shared.token(.fcmToken, success: true, details: "FCM 토큰 저장 완료")
    }
    
    func getFCMToken() -> String? {
        return read(.fcmToken)
    }
    
    func deleteFCMToken() {
        delete(.fcmToken)
        GTLogger.shared.token(.fcmToken, success: true, details: "FCM 토큰 삭제 완료")
    }
}

// MARK: - 토큰 검증 및 강화된 저장 시스템
extension KeychainManager {
    
    /// 토큰 저장 후 검증까지 포함한 안전한 저장
    func saveTokenWithValidation(_ token: String, key: KeychainKey) throws {
        // 1. 토큰 내용 사전 검증
        try validateTokenContent(token, for: key)
        
        // 2. 기존 토큰 백업 (롤백용)
        let originalToken = read(key)
        
        // 3. 토큰 저장 시도
        save(token, key: key)
        
        // 4. 저장 후 검증
        try verifyTokenStorage(token, key: key, originalToken: originalToken)
        
        GTLogger.shared.token(key, success: true, details: "검증된 토큰 저장 완료")
    }
    
    /// 토큰 내용 유효성 검증
    func validateTokenContent(_ token: String, for key: KeychainKey) throws {
        // 빈 토큰 체크
        guard !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AuthError.tokenContentInvalid
        }
        
        // 토큰 길이 검증 (일반적인 JWT나 Bearer 토큰 기준)
        guard token.count >= 10 && token.count <= 2048 else {
            throw AuthError.tokenLengthMismatch
        }
        
        // Access Token과 Refresh Token의 경우 Bearer 형식 또는 JWT 형식 검증
        if key == .accessToken || key == .refreshToken {
            let trimmedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // JWT 형식 검증 (3개 부분으로 나뉘는지 확인)
            let components = trimmedToken.components(separatedBy: ".")
            if components.count == 3 {
                // JWT 형식으로 보임 - 각 부분이 Base64로 인코딩되어 있는지 확인
                for component in components {
                    guard isValidBase64Component(component) else {
                        throw AuthError.tokenValidationFailed(reason: "JWT 형식이 올바르지 않음")
                    }
                }
            } else if !trimmedToken.hasPrefix("Bearer ") && trimmedToken.count < 20 {
                // JWT도 아니고 Bearer 형식도 아니며 너무 짧은 경우
                throw AuthError.tokenValidationFailed(reason: "토큰 형식이 올바르지 않음")
            }
        }
        
        // 유효하지 않은 문자 체크
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: ".-_="))
        if key == .accessToken || key == .refreshToken {
            let tokenWithoutBearer = token.replacingOccurrences(of: "Bearer ", with: "")
            if tokenWithoutBearer.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
                throw AuthError.tokenValidationFailed(reason: "허용되지 않은 문자가 포함됨")
            }
        }
    }
    
    /// Base64 컴포넌트 유효성 검사
    private func isValidBase64Component(_ component: String) -> Bool {
        // Base64 URL-safe 문자들 (JWT에서 사용)
        let base64Characters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_="))
        return component.rangeOfCharacter(from: base64Characters.inverted) == nil && !component.isEmpty
    }
    
    /// 토큰 저장 후 검증
    private func verifyTokenStorage(_ expectedToken: String, key: KeychainKey, originalToken: String?) throws {
        // 저장된 토큰 즉시 읽기
        guard let storedToken = read(key) else {
            // 저장 실패 - 원본 토큰 복구 시도
            if let original = originalToken {
                save(original, key: key)
                GTLogger.e("토큰 저장 실패로 원본 복구 시도")
            }
            throw AuthError.tokenValidationFailed(reason: "저장된 토큰을 읽을 수 없음")
        }
        
        // 토큰 내용 일치 확인
        guard storedToken == expectedToken else {
            // 토큰 불일치 - 원본 토큰 복구 시도
            if let original = originalToken {
                save(original, key: key)
                GTLogger.e("토큰 불일치로 원본 복구 시도: 예상=\(expectedToken.prefix(10))..., 실제=\(storedToken.prefix(10))...")
            }
            throw AuthError.tokenStateInconsistent
        }
        
        // 키체인 무결성 검증 (여러 번 읽어서 일관성 확인)
        try verifyKeychainIntegrity(for: key, expectedToken: expectedToken)
    }
    
    /// 키체인 무결성 검증
    func verifyKeychainIntegrity(for key: KeychainKey, expectedToken: String) throws {
        // 0.1초 간격으로 3번 읽어서 일관성 확인
        for i in 1...3 {
            Thread.sleep(forTimeInterval: 0.1)
            
            guard let verificationToken = read(key) else {
                throw AuthError.keychainStorageCorrupted
            }
            
            guard verificationToken == expectedToken else {
                GTLogger.e("키체인 무결성 검증 실패 (시도 \(i)): 예상=\(expectedToken.prefix(10))..., 실제=\(verificationToken.prefix(10))...")
                throw AuthError.keychainStorageCorrupted
            }
        }
        
        GTLogger.shared.token(key, success: true, details: "키체인 무결성 검증 통과")
    }
    
    /// 토큰 상태 종합 검증
    func validateTokenState() throws {
        let accessToken = getAccessToken()
        let refreshToken = getRefreshToken()
        
        // 토큰 쌍 검증
        if accessToken != nil && refreshToken == nil {
            throw AuthError.tokenStateInconsistent
        }
        
        if accessToken == nil && refreshToken != nil {
            throw AuthError.tokenStateInconsistent
        }
        
        // 토큰 내용 재검증
        if let access = accessToken {
            try validateTokenContent(access, for: .accessToken)
        }
        
        if let refresh = refreshToken {
            try validateTokenContent(refresh, for: .refreshToken)
        }
        
        GTLogger.shared.auth("토큰 상태 검증 완료")
    }
    
    /// 키체인 상태 진단
    func diagnoseKeychainHealth() -> [String: Any] {
        var diagnosis: [String: Any] = [:]
        
        // 각 토큰별 상태 확인
        for key in KeychainKey.allCases {
            let value = read(key)
            diagnosis[key.rawValue] = [
                "exists": value != nil,
                "length": value?.count ?? 0,
                "isEmpty": value?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
            ]
        }
        
        // 키체인 응답 시간 측정
        let startTime = CFAbsoluteTimeGetCurrent()
        _ = read(.accessToken)
        let responseTime = CFAbsoluteTimeGetCurrent() - startTime
        diagnosis["responseTime"] = responseTime
        
        // 키체인 일관성 확인
        diagnosis["isConsistent"] = checkKeychainConsistency()
        
        return diagnosis
    }
    
    /// 키체인 일관성 확인
    private func checkKeychainConsistency() -> Bool {
        // 같은 키를 여러 번 읽어서 일관된 결과가 나오는지 확인
        let testKey = KeychainKey.accessToken
        let firstRead = read(testKey)
        
        for _ in 0..<5 {
            let currentRead = read(testKey)
            if firstRead != currentRead {
                return false
            }
        }
        
        return true
    }
    
    /// 키체인 에러 상세 분석
    private func analyzeKeychainError(_ status: OSStatus, operation: String, key: KeychainKey) -> String {
        let basicError = "KeyChain \(operation) 실패 (상태: \(status))"
        
        switch status {
        case errSecDuplicateItem:
            return "\(basicError) - 중복 항목 존재. 업데이트 시도 필요"
            
        case errSecItemNotFound:
            return "\(basicError) - 항목을 찾을 수 없음. 새로 생성 필요"
            
        case errSecAuthFailed:
            return "\(basicError) - 인증 실패. 사용자 인증 필요"
            
//        case errSecUserCancel:
//            return "\(basicError) - 사용자가 작업을 취소함"
            
        case errSecInteractionNotAllowed:
            let deviceState = getDeviceSecurityState()
            return "\(basicError) - 상호작용 불가 (\(deviceState)). 디바이스 잠금 해제 필요"
            
        case errSecDecode:
            return "\(basicError) - 데이터 디코딩 실패. 손상된 키체인 데이터"
            
        case errSecAllocate:
            let memoryInfo = getMemoryStatus()
            return "\(basicError) - 메모리 할당 실패 (\(memoryInfo))"
            
        case errSecNotAvailable:
            return "\(basicError) - 키체인 서비스 비활성화. iOS 업데이트 또는 복원 후 발생 가능"
            
        case errSecParam:
            return "\(basicError) - 잘못된 매개변수. 키체인 쿼리 오류"
            
        case errSecIO:
            let storageInfo = getStorageStatus()
            return "\(basicError) - I/O 오류 (\(storageInfo)). 디스크 문제 가능성"
            
        case errSecOpWr:
            return "\(basicError) - 쓰기 권한 없음. 앱 권한 확인 필요"
            
        case errSecInternalComponent:
            return "\(basicError) - 내부 컴포넌트 오류. iOS 시스템 문제"
            
        case errSecCoreFoundationUnknown:
            return "\(basicError) - Core Foundation 알 수 없는 오류"
            
        default:
            let diagnostics = performExtendedDiagnostics(for: key)
            return "\(basicError) - 알 수 없는 오류 (\(diagnostics))"
        }
    }
    
    /// 디바이스 보안 상태 확인
    private func getDeviceSecurityState() -> String {
        var state: [String] = []
        
        // 디바이스 잠금 상태 확인
        let isLocked = UIApplication.shared.isProtectedDataAvailable
        state.append(isLocked ? "잠금해제됨" : "잠김")
        
        // 백그라운드 상태 확인
        let appState = UIApplication.shared.applicationState
        switch appState {
        case .active:
            state.append("활성상태")
        case .background:
            state.append("백그라운드")
        case .inactive:
            state.append("비활성상태")
        @unknown default:
            state.append("알수없음")
        }
        
        return state.joined(separator: ", ")
    }
    
    /// 메모리 상태 확인
    private func getMemoryStatus() -> String {
        var memoryInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &memoryInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let usedMB = Double(memoryInfo.resident_size) / 1024 / 1024
            return String(format: "사용중: %.1fMB", usedMB)
        } else {
            return "메모리 정보 확인 실패"
        }
    }
    
    /// 저장소 상태 확인
    private func getStorageStatus() -> String {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return "경로 확인 실패"
        }
        
        do {
            let resourceValues = try documentsPath.resourceValues(forKeys: [.volumeAvailableCapacityKey])
            if let availableCapacity = resourceValues.volumeAvailableCapacity {
                let availableMB = Double(availableCapacity) / 1024 / 1024
                return String(format: "가용용량: %.1fMB", availableMB)
            }
        } catch {
            return "저장소 정보 확인 실패: \(error.localizedDescription)"
        }
        
        return "저장소 상태 불명"
    }
    
    /// 확장 진단 수행
    private func performExtendedDiagnostics(for key: KeychainKey) -> String {
        var diagnostics: [String] = []
        
        // 키체인 서비스 접근 테스트
        let testStatus = testKeychainAccess()
        diagnostics.append("접근테스트: \(testStatus)")
        
        // 동시 접근 확인
        let concurrentTest = testConcurrentAccess()
        diagnostics.append("동시접근: \(concurrentTest)")
        
        // 다른 키들의 상태 확인
        let otherKeysStatus = checkOtherKeysStatus(excluding: key)
        diagnostics.append("다른키상태: \(otherKeysStatus)")
        
        return diagnostics.joined(separator: ", ")
    }
    
    /// 키체인 접근 테스트
    private func testKeychainAccess() -> String {
        let testKey = KeychainKey.deviceId
        let testValue = "test_\(Date().timeIntervalSince1970)"
        
        // 테스트 쓰기
        save(testValue, key: testKey)
        
        // 테스트 읽기
        let readValue = read(testKey)
        
        // 테스트 삭제
        delete(testKey)
        
        if readValue == testValue {
            return "정상"
        } else {
            return "읽기실패"
        }
    }
    
    /// 동시 접근 테스트
    private func testConcurrentAccess() -> String {
        let group = DispatchGroup()
        var results: [Bool] = []
        let testKey = KeychainKey.deviceId
        
        for i in 0..<3 {
            group.enter()
            DispatchQueue.global().async {
                let testValue = "concurrent_test_\(i)"
                self.save(testValue, key: testKey)
                let readValue = self.read(testKey)
                results.append(readValue != nil)
                group.leave()
            }
        }
        
        let timeoutResult = group.wait(timeout: .now() + 2.0)
        
        if timeoutResult == .timedOut {
            return "시간초과"
        } else if results.allSatisfy({ $0 }) {
            return "정상"
        } else {
            return "일부실패"
        }
    }
    
    /// 다른 키들의 상태 확인
    private func checkOtherKeysStatus(excluding key: KeychainKey) -> String {
        let otherKeys = KeychainKey.allCases.filter { $0 != key }
        let workingKeys = otherKeys.filter { read($0) != nil }.count
        
        return "\(workingKeys)/\(otherKeys.count)정상"
    }
}
