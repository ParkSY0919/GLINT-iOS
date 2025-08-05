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
        }
    }
}
