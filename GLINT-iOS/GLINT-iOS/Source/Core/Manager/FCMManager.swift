//
//  FCMManager.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/15/25.
//

import UIKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging
import Combine

@MainActor
final class FCMManager: NSObject, ObservableObject {
    static let shared = FCMManager()
    
    @Published var fcmToken: String?
    @Published var isNotificationPermissionGranted: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Manager Dependencies
    private let permissionManager = NotificationPermissionManager.shared
    private let appStateManager = AppStateManager.shared
    private let preferencesManager = NotificationPreferencesManager.shared
    
    override init() {
        super.init()
        setupNotificationObservers()
        setupManagerIntegration()
    }
    
    // MARK: - Firebase 초기화
    func configure() {
        // Firebase 설정
        FirebaseApp.configure()
        
        // FCM delegate 설정
        Messaging.messaging().delegate = self
        
        // UNUserNotificationCenter delegate 설정
        UNUserNotificationCenter.current().delegate = self
        
        // FCM 토큰은 APNS 토큰 설정 후에 요청 (즉시 요청하지 않음)
        print("🔥 Firebase FCM 기본 설정 완료 (토큰 요청 대기 중)")
    }
    
    /// APNS 토큰 설정 후 FCM 토큰 요청
    func requestFCMTokenAfterAPNS() {
        requestFCMToken()
        print("🔥 APNS 토큰 설정 후 FCM 토큰 요청 시작")
    }
    
    // MARK: - 푸시 알림 권한 요청 (개선된 버전)
    func requestNotificationPermission() async -> Bool {
        let granted = await permissionManager.requestNotificationPermission()
        
        await MainActor.run {
            self.isNotificationPermissionGranted = granted
        }
        
        return granted
    }
    
    // 호환성을 위한 기존 메서드 유지
    func requestNotificationPermission() {
        Task {
            _ = await requestNotificationPermission()
        }
    }
    
    // MARK: - FCM 토큰 관리
    private func requestFCMToken() {
        Messaging.messaging().token { [weak self] token, error in
            if let error = error {
                print("❌ FCM 토큰 요청 실패: \(error)")
                return
            }
            
            guard let token = token else {
                print("❌ FCM 토큰이 nil입니다")
                return
            }
            
            DispatchQueue.main.async {
                self?.fcmToken = token
                self?.saveFCMToken(token)
                print("🔥 FCM 토큰 받음: \(token)")
            }
        }
    }
    
    private func saveFCMToken(_ token: String) {
        KeychainManager.shared.saveFCMToken(token)
        // 서버에 토큰 전송 (필요 시)
//        sendTokenToServer(token)
        
        // FCM 토큰 설정 완료 후 사용자 토픽 자동 구독
        subscribeToUserTopicIfNeeded()
    }
    
    /// 사용자 로그인 상태에 따른 토픽 자동 구독
    private func subscribeToUserTopicIfNeeded() {
        if let userId = KeychainManager.shared.getUserId() {
            subscribeToTopic("user_\(userId)")
            print("🔥 FCM 토큰 설정 완료 - 사용자 토픽 자동 구독: user_\(userId)")
        }
    }
    
    func sendTokenToServer(_ token: String) {
        // FCM 토큰을 서버에 전송
        Task {
            do {
                // TODO: FCM 토큰 전송 API EndPoint 추가 필요
                // let provider = NetworkService<UserEndPoint>()
                // try await provider.request(.updateFCMToken(token: token))
                
                print("📤 서버에 FCM 토큰 전송 성공: \(token)")
            } catch {
                print("❌ 서버에 FCM 토큰 전송 실패: \(error)")
            }
        }
    }
    
    // MARK: - 토픽 구독
    func subscribeToTopic(_ topic: String) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let error = error {
                print("❌ 토픽 구독 실패 (\(topic)): \(error)")
            } else {
                print("✅ 토픽 구독 성공: \(topic)")
            }
        }
    }
    
    func unsubscribeFromTopic(_ topic: String) {
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            if let error = error {
                print("❌ 토픽 구독 해제 실패 (\(topic)): \(error)")
            } else {
                print("✅ 토픽 구독 해제 성공: \(topic)")
            }
        }
    }
    
    // MARK: - 알림 처리 (개선된 버전)
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        print("📱 푸시 알림 수신: \(userInfo)")
        
        // 채팅 관련 푸시 알림 처리
        if let roomId = userInfo["roomId"] as? String,
           let messageContent = userInfo["content"] as? String {
            handleChatNotification(roomId: roomId, content: messageContent, userInfo: userInfo)
        }
        
        // 다른 타입의 알림 처리
        handleSystemNotification(userInfo)
    }
    
    private func handleChatNotification(roomId: String, content: String, userInfo: [AnyHashable: Any]) {
        print("💬 채팅 푸시 알림 처리: 방 ID \(roomId), 내용: \(content)")
        
        let preferences = preferencesManager.loadPreferences()
        let isInForeground = appStateManager.isAppInForeground
        let isActiveRoom = appStateManager.currentActiveRoomId == roomId && appStateManager.isUserInChatRoom
        
        // 알림 표시 여부 결정
        let shouldShowNotification = preferences.shouldShowChatNotification(
            for: roomId,
            isInForeground: isInForeground,
            isActiveRoom: isActiveRoom
        )
        
        print("🔔 알림 표시 결정:")
        print("   - 방 ID: \(roomId)")
        print("   - 포그라운드: \(isInForeground)")
        print("   - 활성 방: \(isActiveRoom)")
        print("   - 알림 표시: \(shouldShowNotification)")
        
        if shouldShowNotification {
            // 시스템 푸시 알림 표시 (백그라운드 또는 다른 방)
            handleSystemPushNotification(roomId: roomId, content: content, userInfo: userInfo)
        } else if isInForeground && isActiveRoom {
            // 현재 활성 채팅방인 경우 인앱 알림만 표시
            handleInAppNotification(roomId: roomId, content: content)
        }
        
        // WebSocket을 통해 실시간 메시지 동기화
        WebSocketManager.shared.syncChatRoom(roomId: roomId)
        
        // 배지 카운트 업데이트
        updateBadgeCount()
    }
    
    private func handleSystemNotification(_ userInfo: [AnyHashable: Any]) {
        // 시스템 알림 처리 로직
        print("📱 시스템 알림 처리: \(userInfo)")
        
        let preferences = preferencesManager.loadPreferences()
        guard preferences.systemNotificationsEnabled else {
            print("🔕 시스템 알림이 비활성화됨")
            return
        }
        
        // 시스템 알림 표시 로직
    }
    
    private func handleSystemPushNotification(roomId: String, content: String, userInfo: [AnyHashable: Any]) {
        // 권한 확인
        guard permissionManager.currentStatus.canShowNotifications else {
            print("🔕 알림 권한 없음 - 시스템 푸시 알림 건너뜀")
            permissionManager.showInAppNotification(
                title: "새 메시지",
                message: content,
                roomId: roomId
            )
            return
        }
        
        print("📱 시스템 푸시 알림 표시: \(content)")
        // 실제 시스템 푸시 알림은 이미 시스템에서 처리됨
    }
    
    private func handleInAppNotification(roomId: String, content: String) {
        print("📱 인앱 알림 표시: \(content)")
        
        // 인앱 알림 표시
        permissionManager.showInAppNotification(
            title: "새 메시지",
            message: content,
            roomId: roomId
        )
    }
    
    private func updateBadgeCount() {
        // TODO: 실제 읽지 않은 메시지 수 계산 로직 구현
        let unreadCount = 0 // CoreData에서 계산
        permissionManager.updateBadgeCount(unreadCount)
    }
    
    // MARK: - Notification Observers
    private func setupNotificationObservers() {
        // 앱이 활성화될 때 토큰 새로고침
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.requestFCMToken()
            }
            .store(in: &cancellables)
        
        // 앱이 백그라운드로 갈 때
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { _ in
                print("📱 앱이 백그라운드로 이동 - FCM 상태 유지")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Manager Integration
    private func setupManagerIntegration() {
        // 권한 상태 변경 감지
        permissionManager.$currentStatus
            .sink { [weak self] status in
                self?.isNotificationPermissionGranted = status.canShowNotifications
                print("📱 FCM: 권한 상태 변경됨 - \(status)")
            }
            .store(in: &cancellables)
        
        // 앱 상태 변경 감지
        appStateManager.$currentAppState
            .sink { [weak self] appState in
                print("📱 FCM: 앱 상태 변경됨 - \(appState)")
                self?.handleAppStateChange(appState)
            }
            .store(in: &cancellables)
        
        // 채팅방 상태 변경 감지
        appStateManager.$currentActiveRoomId
            .sink { [weak self] roomId in
                print("📱 FCM: 활성 채팅방 변경됨 - \(roomId ?? "없음")")
            }
            .store(in: &cancellables)
    }
    
    private func handleAppStateChange(_ appState: AppState) {
        switch appState {
        case .foreground:
            // 포그라운드 진입 시 권한 상태 재확인
            Task {
                await permissionManager.checkCurrentPermissionStatus()
            }
            
        case .background:
            // 백그라운드 진입 시 배지 카운트 업데이트
            updateBadgeCount()
            
        case .inactive:
            break
        }
    }
}

// MARK: - MessagingDelegate
extension FCMManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("🔥 FCM 토큰 갱신: \(fcmToken ?? "nil")")
        
        guard let fcmToken = fcmToken else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.fcmToken = fcmToken
            self?.saveFCMToken(fcmToken)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension FCMManager: UNUserNotificationCenterDelegate {
    // 앱이 포그라운드에 있을 때 알림 수신
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        handleRemoteNotification(userInfo)
        
        // 채팅 알림인 경우 현재 활성 채팅방 확인
        if let roomId = userInfo["roomId"] as? String {
            let shouldSuppressNotification = appStateManager.shouldSuppressNotification(for: roomId)
            
            if shouldSuppressNotification {
                print("🔕 포그라운드 알림 억제: 현재 활성 채팅방 (\(roomId))")
                completionHandler([]) // 알림 표시 안함
                return
            }
        }
        
        // 권한 설정에 따른 알림 옵션 결정
        let preferences = preferencesManager.loadPreferences()
        var options: UNNotificationPresentationOptions = []
        
        if permissionManager.authorizationDetails?.alertsEnabled == true && 
           !preferences.isInQuietHours() {
            options.insert(.banner)
        }
        
        if permissionManager.authorizationDetails?.soundsEnabled == true && 
           preferences.chatSoundsEnabled {
            options.insert(.sound)
        }
        
        if permissionManager.authorizationDetails?.badgesEnabled == true && 
           preferences.badgeCountEnabled {
            options.insert(.badge)
        }
        
        completionHandler(options)
    }
    
    // 알림을 탭했을 때
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        handleRemoteNotification(userInfo)
        
        // 알림 탭 시 특정 화면으로 이동
        handleNotificationTap(userInfo: userInfo)
        
        completionHandler()
    }
    
    //FIX - 보완 필요
    private func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        print("👆 푸시 알림 탭됨: \(userInfo)")
        
        // 채팅 알림 탭 시 해당 채팅방으로 이동
        if let roomId = userInfo["roomId"] as? String {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // TODO: NavigationRouter를 통해 채팅방 이동
                ChatNotificationHelper.postNavigateToRoom(roomId)
            }
        }
    }
}

// MARK: - Notification Names are now managed in ChatNotifications.swift 
