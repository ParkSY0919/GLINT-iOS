//
//  AttendanceViewStore.swift
//  GLINT-iOS
//
//  Created by Claude on 8/9/25.
//

import SwiftUI

@Observable
final class AttendanceViewStore {
    
    // MARK: - Properties
    private var webViewCoordinator: AttendanceWebView.Coordinator?
    private var authTokenExpiredObserver: NSObjectProtocol?
    
    // MARK: - State
    var isLoading: Bool = false
    var errorMessage: String?
    var showCompletionAlert: Bool = false
    var lastAttendanceCount: Int = 0
    var showTokenRefreshAlert: Bool = false
    var showRetryButton: Bool = false
    var webViewLoadFailed: Bool = false
    
    // MARK: - Actions
    enum Action {
        case webViewLoaded(coordinator: AttendanceWebView.Coordinator)
        case messageReceived(AttendanceMessage)
        case dismissError
        case dismissCompletionAlert
        case dismissTokenRefreshAlert
        case retryButtonTapped
        case webViewLoadFailed
        case viewWillAppear
    }
    
    // MARK: - Methods
    func send(_ action: Action) {
        switch action {
        case .webViewLoaded(let coordinator):
            webViewCoordinator = coordinator
            
        case .messageReceived(let message):
            handleWebMessage(message)
            
        case .dismissError:
            errorMessage = nil
            showRetryButton = false
            
        case .dismissCompletionAlert:
            showCompletionAlert = false
            
        case .dismissTokenRefreshAlert:
            showTokenRefreshAlert = false
            
        case .retryButtonTapped:
            handleRetryButtonTapped()
            
        case .webViewLoadFailed:
            handleWebViewLoadFailed()
            
        case .viewWillAppear:
            handleViewWillAppear()
        }
    }
    
    private func handleWebMessage(_ message: AttendanceMessage) {
        switch message {
        case .clickAttendanceButton:
            handleAttendanceButtonClick()
            
        case .completeAttendance(let count):
            handleAttendanceCompletion(count: count)
        }
    }
    
    private func handleAttendanceButtonClick() {
        print("📋 출석 버튼 클릭됨")
        
        // 액세스 토큰 가져오기
        guard let accessToken = KeychainManager.shared.getAccessToken() else {
            showTokenRefreshRequired("로그인이 필요합니다.")
            print("❌ 액세스 토큰이 없습니다.")
            return
        }
        
        // 웹으로 액세스 토큰 전송
        sendAccessTokenToWeb(accessToken)
    }
    
    private func sendAccessTokenToWeb(_ accessToken: String) {
        guard let coordinator = webViewCoordinator else {
            showErrorMessage("웹뷰 연결에 실패했습니다. 다시 시도해주세요.", shouldShowRetry: true)
            return
        }
        
        isLoading = true
        
        // JavaScript 실행 결과 콜백으로 처리
        coordinator.sendAccessToken(accessToken) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if success {
                    print("✅ 액세스 토큰 전송 성공: \(accessToken.prefix(10))...")
                } else {
                    let errorMsg = error?.localizedDescription ?? "토큰 전송에 실패했습니다."
                    print("❌ 액세스 토큰 전송 실패: \(errorMsg)")
                    
                    // 토큰 관련 에러인지 확인
                    if errorMsg.contains("token") || errorMsg.contains("auth") {
                        self?.showTokenRefreshRequired("로그인 정보가 만료되었습니다.")
                    } else {
                        self?.showErrorMessage("토큰 전송에 실패했습니다. 다시 시도해주세요.", shouldShowRetry: true)
                    }
                }
            }
        }
    }
    
    private func handleAttendanceCompletion(count: Int) {
        print("🎉 출석 완료! 출석 횟수: \(count)")
        lastAttendanceCount = count
        showCompletionAlert = true
        
        // 추가적인 작업 수행 가능 (예: 알림, 네비게이션 등)
        // 예시: 성공 피드백
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // 햅틱 피드백
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }
    
    // MARK: - 새로운 액션 처리 메서드들
    
    private func handleViewWillAppear() {
        setupAuthTokenObserver()
        validateTokenBeforeLoad()
    }
    
    private func handleRetryButtonTapped() {
        errorMessage = nil
        showRetryButton = false
        webViewLoadFailed = false
        
        if let coordinator = webViewCoordinator {
            coordinator.reloadWebView()
        }
    }
    
    private func handleWebViewLoadFailed() {
        webViewLoadFailed = true
        showErrorMessage("웹페이지를 불러올 수 없습니다.", shouldShowRetry: true)
    }
    
    // MARK: - 토큰 관련 헬퍼 메서드들
    
    private func validateTokenBeforeLoad() {
        guard KeychainManager.shared.getAccessToken() != nil else {
            showTokenRefreshRequired("로그인이 필요합니다.")
            return
        }
    }
    
    private func showTokenRefreshRequired(_ message: String) {
        errorMessage = message
        showTokenRefreshAlert = true
        showRetryButton = false
    }
    
    private func showErrorMessage(_ message: String, shouldShowRetry: Bool = false) {
        errorMessage = message
        showRetryButton = shouldShowRetry
        showTokenRefreshAlert = false
    }
    
    private func setupAuthTokenObserver() {
        guard authTokenExpiredObserver == nil else { return }
        
        authTokenExpiredObserver = NotificationCenter.default.addObserver(
            forName: .authTokenExpired,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAuthTokenExpired()
        }
    }
    
    private func handleAuthTokenExpired() {
        print("🚨 토큰 만료 알림 수신됨")
        showTokenRefreshRequired("로그인 정보가 만료되었습니다. 다시 로그인해주세요.")
    }
    
    // MARK: - Cleanup
    
    deinit {
        if let observer = authTokenExpiredObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

// MARK: - Computed Properties
extension AttendanceViewStore {
    var completionMessage: String {
        return "\(lastAttendanceCount)번째 출석이 완료되었습니다!"
    }
}