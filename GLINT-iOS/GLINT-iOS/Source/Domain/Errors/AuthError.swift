//
//  AuthError.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/19/25.
//

import Foundation

enum AuthError: LocalizedError {
    case noTokenFound
    case tokenRefreshFailed
    case tokenSaveFailed
    case tokenSyncFailed
    case multipleRefreshAttempts
    case tokenMismatch
    case invalidEmailFormat
    case invalidPasswordFormat
    case noDeviceTokenFound
    case noData
    
    // 토큰 저장 검증 관련 세분화된 에러
    case tokenValidationFailed(reason: String)
    case keychainStorageCorrupted
    case tokenContentInvalid
    case tokenLengthMismatch
    case keychainAccessDenied
    case deviceStorageFull
    case tokenStateInconsistent
    
    var errorDescription: String? {
        switch self {
        case .noTokenFound: return "저장된 토큰이 없습니다."
        case .tokenRefreshFailed: return "토큰 갱신에 실패했습니다."
        case .tokenSaveFailed: return "토큰 저장에 실패했습니다."
        case .tokenSyncFailed: return "토큰 동기화에 실패했습니다."
        case .multipleRefreshAttempts: return "다중 토큰 갱신 시도가 감지되었습니다."
        case .tokenMismatch: return "토큰 불일치가 감지되었습니다."
        case .invalidEmailFormat: return "올바른 이메일 형식이 아닙니다."
        case .invalidPasswordFormat: return "올바른 비밀번호 형식이 아닙니다."
        case .noDeviceTokenFound: return "디바이스 토큰이 없습니다."
        case .noData: return "데이터가 없습니다."
        case .tokenValidationFailed(let reason): return "토큰 검증 실패: \(reason)"
        case .keychainStorageCorrupted: return "키체인 저장소가 손상되었습니다."
        case .tokenContentInvalid: return "토큰 내용이 유효하지 않습니다."
        case .tokenLengthMismatch: return "토큰 길이가 예상과 다릅니다."
        case .keychainAccessDenied: return "키체인 접근이 거부되었습니다."
        case .deviceStorageFull: return "디바이스 저장공간이 부족합니다."
        case .tokenStateInconsistent: return "토큰 상태가 일관되지 않습니다."
        }
    }
}
