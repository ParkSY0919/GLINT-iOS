//
//  TokenErrorMessageProvider.swift
//  GLINT-iOS
//
//  Created by Claude on 8/15/25.
//

import Foundation
import Network

/// 토큰 관련 오류에 대한 사용자 친화적 메시지 제공
struct TokenErrorMessageProvider {
    
    /// 사용자 메시지 타입
    enum UserMessageType {
        case info(title: String, message: String, action: String?)
        case warning(title: String, message: String, action: String?)
        case error(title: String, message: String, action: String?)
        case critical(title: String, message: String, action: String?)
    }
    
    /// 네트워크 상태 확인
    private static func getNetworkStatus() -> String {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        var status = "확인중"
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                if path.usesInterfaceType(.wifi) {
                    status = "WiFi 연결됨"
                } else if path.usesInterfaceType(.cellular) {
                    status = "셀룰러 연결됨"
                } else {
                    status = "기타 네트워크 연결됨"
                }
            } else {
                status = "네트워크 연결 안됨"
            }
        }
        
        monitor.start(queue: queue)
        Thread.sleep(forTimeInterval: 0.1) // 짧은 대기
        monitor.cancel()
        
        return status
    }
    
    /// AuthError를 사용자 친화적 메시지로 변환
    static func getUserMessage(for error: Error) -> UserMessageType {
        guard let authError = error as? AuthError else {
            return .error(
                title: "오류 발생",
                message: "예상치 못한 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.",
                action: "다시 시도"
            )
        }
        
        switch authError {
        case .noTokenFound:
            return .info(
                title: "로그인 필요",
                message: "로그인이 필요한 서비스입니다.\n로그인 후 이용해주세요.",
                action: "로그인하기"
            )
            
        case .tokenRefreshFailed:
            let networkStatus = getNetworkStatus()
            if networkStatus.contains("연결 안됨") {
                return .warning(
                    title: "네트워크 연결 확인",
                    message: "네트워크 연결을 확인한 후\n다시 시도해주세요.",
                    action: "다시 시도"
                )
            } else {
                return .warning(
                    title: "인증 갱신 실패",
                    message: "로그인 정보를 갱신하지 못했습니다.\n다시 로그인해주세요.",
                    action: "다시 로그인"
                )
            }
            
        case .tokenSaveFailed:
            return .error(
                title: "저장 오류",
                message: "로그인 정보 저장에 실패했습니다.\n디바이스 저장공간을 확인해주세요.",
                action: "확인"
            )
            
        case .tokenValidationFailed(let reason):
            return .error(
                title: "인증 오류",
                message: "로그인 정보에 문제가 있습니다.\n(\(reason))\n다시 로그인해주세요.",
                action: "다시 로그인"
            )
            
        case .keychainStorageCorrupted:
            return .critical(
                title: "보안 저장소 오류",
                message: "디바이스의 보안 저장소에 문제가 발생했습니다.\n앱을 재시작하거나 디바이스를 재부팅해주세요.",
                action: "앱 재시작"
            )
            
        case .tokenContentInvalid:
            return .error(
                title: "로그인 정보 오류",
                message: "저장된 로그인 정보가 손상되었습니다.\n다시 로그인해주세요.",
                action: "다시 로그인"
            )
            
        case .tokenLengthMismatch:
            return .error(
                title: "로그인 정보 오류",
                message: "로그인 정보 형식에 문제가 있습니다.\n다시 로그인해주세요.",
                action: "다시 로그인"
            )
            
        case .keychainAccessDenied:
            return .critical(
                title: "접근 권한 오류",
                message: "보안 저장소 접근이 거부되었습니다.\n디바이스 잠금을 해제하고 다시 시도해주세요.",
                action: "다시 시도"
            )
            
        case .deviceStorageFull:
            return .critical(
                title: "저장공간 부족",
                message: "디바이스 저장공간이 부족합니다.\n불필요한 파일을 삭제한 후 다시 시도해주세요.",
                action: "확인"
            )
            
        case .tokenStateInconsistent:
            return .critical(
                title: "보안 문제 감지",
                message: "로그인 상태에 이상이 감지되었습니다.\n보안을 위해 다시 로그인해주세요.",
                action: "다시 로그인"
            )
            
        case .tokenSyncFailed:
            return .warning(
                title: "동기화 실패",
                message: "로그인 정보 동기화에 실패했습니다.\n잠시 후 다시 시도해주세요.",
                action: "다시 시도"
            )
            
        case .multipleRefreshAttempts:
            return .warning(
                title: "동시 접속 감지",
                message: "여러 곳에서 동시에 접속을 시도했습니다.\n잠시 후 다시 시도해주세요.",
                action: "잠시 후 재시도"
            )
            
        case .tokenMismatch:
            return .warning(
                title: "로그인 정보 불일치",
                message: "로그인 정보가 일치하지 않습니다.\n다시 로그인해주세요.",
                action: "다시 로그인"
            )
            
        default:
            return .error(
                title: "인증 오류",
                message: "로그인 관련 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.",
                action: "다시 시도"
            )
        }
    }
    
    /// 컨텍스트별 메시지 커스터마이징
    static func getContextualMessage(for error: Error, context: String) -> UserMessageType {
        let baseMessage = getUserMessage(for: error)
        
        switch context {
        case "login":
            return customizeForLogin(baseMessage)
        case "api_call":
            return customizeForAPICall(baseMessage)
        case "background":
            return customizeForBackground(baseMessage)
        case "app_launch":
            return customizeForAppLaunch(baseMessage)
        default:
            return baseMessage
        }
    }
    
    /// 로그인 컨텍스트용 메시지 커스터마이징
    private static func customizeForLogin(_ message: UserMessageType) -> UserMessageType {
        switch message {
        case .error(let title, _, let action):
            return .error(
                title: title,
                message: "로그인 처리 중 문제가 발생했습니다.\n네트워크 연결을 확인하고 다시 시도해주세요.",
                action: action
            )
        default:
            return message
        }
    }
    
    /// API 호출 컨텍스트용 메시지 커스터마이징
    private static func customizeForAPICall(_ message: UserMessageType) -> UserMessageType {
        switch message {
        case .warning(let title, _, let action):
            return .warning(
                title: title,
                message: "서비스 이용 중 인증 문제가 발생했습니다.\n로그인 상태를 확인해주세요.",
                action: action
            )
        default:
            return message
        }
    }
    
    /// 백그라운드 컨텍스트용 메시지 커스터마이징
    private static func customizeForBackground(_ message: UserMessageType) -> UserMessageType {
        switch message {
        case .error(let title, _, _):
            return .info(
                title: title,
                message: "앱을 다시 열 때 로그인이 필요할 수 있습니다.",
                action: "확인"
            )
        default:
            return message
        }
    }
    
    /// 앱 실행 컨텍스트용 메시지 커스터마이징
    private static func customizeForAppLaunch(_ message: UserMessageType) -> UserMessageType {
        switch message {
        case .critical(let title, _, let action):
            return .critical(
                title: title,
                message: "앱 실행 중 보안 문제가 감지되었습니다.\n디바이스를 재부팅하고 다시 실행해주세요.",
                action: action
            )
        default:
            return message
        }
    }
    
    /// 복구 제안 메시지 생성
    static func getRecoveryMessage(for error: Error) -> UserMessageType {
        guard let authError = error as? AuthError else {
            return .info(
                title: "문제 해결 도움말",
                message: "• 네트워크 연결 확인\n• 앱 재시작\n• 디바이스 재부팅",
                action: "확인"
            )
        }
        
        switch authError {
        case .keychainStorageCorrupted, .deviceStorageFull:
            return .info(
                title: "문제 해결 방법",
                message: "1. 앱을 완전히 종료 후 재시작\n2. 디바이스 재부팅\n3. iOS 업데이트 확인\n4. 저장공간 확보",
                action: "확인"
            )
            
        case .keychainAccessDenied:
            return .info(
                title: "문제 해결 방법",
                message: "1. 디바이스 잠금 해제\n2. Face ID/Touch ID 설정 확인\n3. 앱 권한 설정 확인",
                action: "확인"
            )
            
        case .tokenRefreshFailed:
            let networkStatus = getNetworkStatus()
            return .info(
                title: "문제 해결 방법",
                message: "네트워크 상태: \(networkStatus)\n\n1. 네트워크 연결 확인\n2. WiFi/셀룰러 데이터 전환\n3. 라우터 재시작\n4. 잠시 후 재시도",
                action: "확인"
            )
            
        default:
            return .info(
                title: "문제 해결 도움말",
                message: "• 네트워크 연결 확인\n• 앱 재시작\n• 다시 로그인\n• 고객지원 문의",
                action: "확인"
            )
        }
    }
    
    /// 진행 상황 메시지 생성 (토큰 갱신 중 등)
    static func getProgressMessage(for operation: String) -> String {
        switch operation {
        case "token_refresh":
            return "로그인 정보를 갱신하고 있습니다..."
        case "token_validation":
            return "로그인 상태를 확인하고 있습니다..."
        case "keychain_recovery":
            return "저장된 정보를 복구하고 있습니다..."
        case "network_retry":
            return "네트워크 연결을 재시도하고 있습니다..."
        default:
            return "처리 중입니다..."
        }
    }
}