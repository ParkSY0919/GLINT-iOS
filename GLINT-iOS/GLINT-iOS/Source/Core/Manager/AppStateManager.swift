//
//  AppStateManager.swift
//  GLINT-iOS
//
//  Created by Claude Code on 8/14/25.
//

import UIKit
import Combine

enum AppState {
    case foreground
    case background
    case inactive
}

@MainActor
final class AppStateManager: ObservableObject {
    static let shared = AppStateManager()
    
    @Published var currentAppState: AppState = .foreground
    @Published var currentActiveRoomId: String?
    @Published var isUserInChatRoom: Bool = false
    @Published var backgroundEnterTime: Date?
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupAppStateObservers()
        updateInitialAppState()
    }
    
    // MARK: - App State Management
    
    private func updateInitialAppState() {
        let state = UIApplication.shared.applicationState
        switch state {
        case .active:
            currentAppState = .foreground
        case .background:
            currentAppState = .background
        case .inactive:
            currentAppState = .inactive
        @unknown default:
            currentAppState = .foreground
        }
        
        print("📱 앱 초기 상태: \(currentAppState)")
    }
    
    private func setupAppStateObservers() {
        // 포그라운드 진입
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppDidBecomeActive()
            }
            .store(in: &cancellables)
        
        // 백그라운드 진입
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.handleAppDidEnterBackground()
            }
            .store(in: &cancellables)
        
        // 비활성 상태
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppWillResignActive()
            }
            .store(in: &cancellables)
        
        // 포그라운드 진입 준비
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.handleAppWillEnterForeground()
            }
            .store(in: &cancellables)
    }
    
    private func handleAppDidBecomeActive() {
        currentAppState = .foreground
        backgroundEnterTime = nil
        
        print("📱 앱 활성화됨")
        notifyAppStateChanged()
    }
    
    private func handleAppDidEnterBackground() {
        currentAppState = .background
        backgroundEnterTime = Date()
        
        print("📱 앱 백그라운드 진입: \(Date())")
        notifyAppStateChanged()
    }
    
    private func handleAppWillResignActive() {
        currentAppState = .inactive
        
        print("📱 앱 비활성화됨")
        notifyAppStateChanged()
    }
    
    private func handleAppWillEnterForeground() {
        print("📱 앱 포그라운드 진입 준비")
        // 상태 변경은 didBecomeActive에서 처리
    }
    
    // MARK: - Chat Room Management
    
    func enterChatRoom(_ roomId: String) {
        currentActiveRoomId = roomId
        isUserInChatRoom = true
        
        print("💬 채팅방 입장: \(roomId)")
        notifyChatRoomStateChanged()
    }
    
    func leaveChatRoom(_ roomId: String? = nil) {
        if let roomId = roomId, currentActiveRoomId == roomId {
            currentActiveRoomId = nil
            isUserInChatRoom = false
        } else if roomId == nil {
            // 모든 채팅방에서 나가기
            currentActiveRoomId = nil
            isUserInChatRoom = false
        }
        
        print("💬 채팅방 퇴장: \(roomId ?? "전체")")
        notifyChatRoomStateChanged()
    }
    
    // MARK: - Notification Decision Logic
    
    func shouldSuppressNotification(for roomId: String) -> Bool {
        // 1. 현재 포그라운드이고 활성 채팅방이 같은 경우 알림 억제
        if currentAppState == .foreground && 
           isUserInChatRoom && 
           currentActiveRoomId == roomId {
            print("🔕 알림 억제: 현재 활성 채팅방 (\(roomId))")
            return true
        }
        
        // 2. 백그라운드거나 다른 채팅방인 경우 알림 허용
        return false
    }
    
    func shouldShowPushNotification(for roomId: String) -> Bool {
        return !shouldSuppressNotification(for: roomId)
    }
    
    // MARK: - App State Utilities
    
    var isAppInForeground: Bool {
        return currentAppState == .foreground
    }
    
    var isAppInBackground: Bool {
        return currentAppState == .background
    }
    
    var backgroundDuration: TimeInterval? {
        guard let backgroundEnterTime = backgroundEnterTime else { return nil }
        return Date().timeIntervalSince(backgroundEnterTime)
    }
    
    // MARK: - Notification Broadcasting
    
    private func notifyAppStateChanged() {
        NotificationCenter.default.post(
            name: .appStateDidChange,
            object: nil,
            userInfo: [
                "appState": currentAppState,
                "isInForeground": isAppInForeground,
                "backgroundDuration": backgroundDuration ?? 0
            ]
        )
    }
    
    private func notifyChatRoomStateChanged() {
        NotificationCenter.default.post(
            name: .chatRoomStateDidChange,
            object: nil,
            userInfo: [
                "activeRoomId": currentActiveRoomId ?? "",
                "isUserInChatRoom": isUserInChatRoom,
                "appState": currentAppState
            ]
        )
    }
    
    // MARK: - Debug Information
    
    func printCurrentState() {
        print("📱 현재 앱 상태:")
        print("   - 앱 상태: \(currentAppState)")
        print("   - 활성 채팅방: \(currentActiveRoomId ?? "없음")")
        print("   - 채팅방 입장 여부: \(isUserInChatRoom)")
        print("   - 백그라운드 진입 시간: \(backgroundEnterTime?.description ?? "없음")")
        if let duration = backgroundDuration {
            print("   - 백그라운드 지속 시간: \(Int(duration))초")
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let appStateDidChange = Notification.Name("appStateDidChange")
    static let chatRoomStateDidChange = Notification.Name("chatRoomStateDidChange")
}