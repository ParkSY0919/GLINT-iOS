//
//  GLogger.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/27/25.
//

import os
import Foundation

final class GLogger {
    static let shared = GLogger()
    
    private let generalLogger: Logger
    private let networkLogger: Logger
    private let authLogger: Logger
    private let uiLogger: Logger
    private let dataLogger: Logger
    
    private let dateFormatter: DateFormatter
    
    private init() {
        self.generalLogger = Logger(subsystem: "com.yourapp.glint", category: "General")
        self.networkLogger = Logger(subsystem: "com.yourapp.glint", category: "Network")
        self.authLogger = Logger(subsystem: "com.yourapp.glint", category: "Auth")
        self.uiLogger = Logger(subsystem: "com.yourapp.glint", category: "UI")
        self.dataLogger = Logger(subsystem: "com.yourapp.glint", category: "Data")
        
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "HH:mm:ss.SSS"
    }
    
    /// 일반적인 정보 로그
    func i(_ message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        generalLogger.info("ℹ️ [\(timestamp)] [\(fileName):\(line)] \(message)")
        #endif
    }
    
    /// Debug 로그
    func d(_ message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        generalLogger.debug("🛠 [\(timestamp)] [\(fileName):\(line)] \(message)")
        #endif
    }
    
    /// Error 로그
    func e(_ message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        generalLogger.error("⚠️ [\(timestamp)] [\(fileName):\(line)] \(message)")
        #endif
    }
    
    /// Warning 로그
    func w(_ message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        generalLogger.warning("⚠️ [\(timestamp)] [\(fileName):\(line)] \(message)")
        #endif
    }
    
    /// Critical 로그 (시스템 레벨 중요 오류)
    func critical(_ message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        generalLogger.critical("🚨 [\(timestamp)] [\(fileName):\(line)] \(message)")
        #endif
    }
    
    /// Fault 로그 (복구 불가능한 오류)
    func fault(_ message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        generalLogger.fault("💥 [\(timestamp)] [\(fileName):\(line)] \(message)")
        #endif
    }
    
    /// Decodable 객체 로깅 (Modern 방식)
    func dump<T: Encodable>(_ object: T, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        
        // JSON 출력
        do {
            let jsonData = try JSONEncoder().encode(object)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let prettyData = try JSONSerialization.jsonObject(with: jsonData)
                let prettyJsonData = try JSONSerialization.data(withJSONObject: prettyData, options: .prettyPrinted)
                if let prettyJsonString = String(data: prettyJsonData, encoding: .utf8) {
                    generalLogger.debug("🖨 [\(timestamp)] [\(fileName):\(line)]\n\(prettyJsonString)")
                    return
                }
            }
        } catch {
            // JSON 인코딩 실패 시 기본 설명 사용
        }
        
        // Fallback: 기본 String 변환
        let objectDescription = String(describing: object)
        generalLogger.debug("🖨 [\(timestamp)] [\(fileName):\(line)] \(objectDescription)")
        #endif
    }
    
    /// 네트워크 요청 시작 로그
    func networkRequest(_ url: String, method: String = "GET", file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        networkLogger.info("🚀 [\(timestamp)] [\(fileName):\(line)] \(method) \(url)")
        #endif
    }
    
    /// 네트워크 응답 성공 로그
    func networkSuccess(_ url: String, statusCode: Int = 200, duration: TimeInterval? = nil, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        if let duration = duration {
            networkLogger.info("✅ [\(timestamp)] [\(fileName):\(line)] \(url) (\(statusCode)) - \(String(format: "%.3fs", duration))")
        } else {
            networkLogger.info("✅ [\(timestamp)] [\(fileName):\(line)] \(url) (\(statusCode))")
        }
        #endif
    }
    
    /// 네트워크 응답 실패 로그
    func networkFailure(_ url: String, error: String, statusCode: Int? = nil, duration: TimeInterval? = nil, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        
        var logMessage = "❌ [\(timestamp)] [\(fileName):\(line)] \(url)"
        if let code = statusCode {
            logMessage += " (\(code))"
        }
        if let duration = duration {
            logMessage += " - \(String(format: "%.3fs", duration))"
        }
        logMessage += " - \(error)"
        
        networkLogger.error("\(logMessage)")
        #endif
    }
    
    /// 네트워크 응답 바디 로그 (상세 디버깅용)
    func networkResponseBody(_ url: String, statusCode: Int, body: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        networkLogger.debug("📄 [\(timestamp)] [\(fileName):\(line)] \(url) (\(statusCode))\nResponse Body:\n\(body)")
        #endif
    }
    
    /// 인증 정보 로그 (민감 정보 제외)
    func auth(_ message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        authLogger.info("🔐 [\(timestamp)] [\(fileName):\(line)] \(message)")
        #endif
    }
    
    /// 토큰 관련 로그 (민감 정보 제외)
    func token(_ action: String, success: Bool, details: String? = nil, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        let status = success ? "SUCCESS" : "FAILED"
        let icon = success ? "✅" : "❌"
        
        var message = "\(icon) [\(timestamp)] [\(fileName):\(line)] Token \(action): \(status)"
        if let details = details {
            message += " - \(details)"
        }
        
        if success {
            authLogger.info("\(message)")
        } else {
            authLogger.error("\(message)")
        }
        #endif
    }
    
    /// UI 이벤트 로그
    func ui(_ message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        uiLogger.info("🎨 [\(timestamp)] [\(fileName):\(line)] \(message)")
        #endif
    }
    
    /// 화면 전환 로그
    func navigation(_ from: String, to: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        uiLogger.info("🧭 [\(timestamp)] [\(fileName):\(line)] \(from) → \(to)")
        #endif
    }
    
    /// 사용자 인터랙션 로그
    func userAction(_ action: String, target: String? = nil, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        if let target = target {
            uiLogger.info("👆 [\(timestamp)] [\(fileName):\(line)] User \(action): \(target)")
        } else {
            uiLogger.info("👆 [\(timestamp)] [\(fileName):\(line)] User \(action)")
        }
        #endif
    }
    
    // MARK: - Data Specific Logging (Modern)
    
    /// 데이터 작업 로그
    func data(_ message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        dataLogger.info("💾 [\(timestamp)] [\(fileName):\(line)] \(message)")
        #endif
    }
    
    /// Repository 작업 로그
    func repository(_ action: String, entity: String, success: Bool, duration: TimeInterval? = nil, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        let status = success ? "✅" : "❌"
        
        var message = "\(status) [\(timestamp)] [\(fileName):\(line)] \(action) \(entity)"
        if let duration = duration {
            message += " - \(String(format: "%.3fs", duration))"
        }
        
        if success {
            dataLogger.info("\(message)")
        } else {
            dataLogger.error("\(message)")
        }
        #endif
    }
    
    /// 캐시 작업 로그
    func cache(_ action: String, key: String, hit: Bool? = nil, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        
        var message = "🗂️ [\(timestamp)] [\(fileName):\(line)] Cache \(action): \(key)"
        if let hit = hit {
            message += hit ? " (HIT)" : " (MISS)"
        }
        
        dataLogger.debug("\(message)")
        #endif
    }
    
    // MARK: - Performance Logging (New)
    
    /// 성능 측정 로그
    func performance(_ operation: String, duration: TimeInterval, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        let durationString = String(format: "%.3fs", duration)
        
        // 느린 작업에 대해 경고
        if duration > 1.0 {
            generalLogger.warning("⏱️ [\(timestamp)] [\(fileName):\(line)] SLOW: \(operation) took \(durationString)")
        } else {
            generalLogger.debug("⏱️ [\(timestamp)] [\(fileName):\(line)] \(operation): \(durationString)")
        }
        #endif
    }
    
    // MARK: - Convenience Static Methods (기존 호환성)
    
    class func i(_ message: String, file: String = #file, line: Int = #line) {
        shared.i(message, file: file, line: line)
    }
    
    class func d(_ message: String, file: String = #file, line: Int = #line) {
        shared.d(message, file: file, line: line)
    }
    
    class func e(_ message: String, file: String = #file, line: Int = #line) {
        shared.e(message, file: file, line: line)
    }
    
    class func dump<T: Codable>(_ object: T, file: String = #file, line: Int = #line) {
        shared.dump(object, file: file, line: line)
    }
}

// MARK: - Performance Measurement Helper
extension GLogger {
    /// 코드 블록 실행 시간을 측정하고 로깅
    func measureTime<T>(
        operation: String,
        file: String = #file,
        line: Int = #line,
        _ block: () throws -> T
    ) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try block()
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        performance(operation, duration: duration, file: file, line: line)
        return result
    }
    
    /// 비동기 코드 블록 실행 시간을 측정하고 로깅
    func measureTimeAsync<T>(
        operation: String,
        file: String = #file,
        line: Int = #line,
        _ block: () async throws -> T
    ) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await block()
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        performance(operation, duration: duration, file: file, line: line)
        return result
    }
}
