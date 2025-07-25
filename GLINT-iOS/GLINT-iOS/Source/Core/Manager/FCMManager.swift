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

final class FCMManager: NSObject, ObservableObject {
    static let shared = FCMManager()
    
    @Published var fcmToken: String?
    @Published var isNotificationPermissionGranted: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupNotificationObservers()
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
    
    // MARK: - 푸시 알림 권한 요청
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isNotificationPermissionGranted = granted
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                    print("✅ 푸시 알림 권한 허용")
                } else {
                    print("❌ 푸시 알림 권한 거부")
                }
                
                if let error = error {
                    print("❌ 푸시 알림 권한 요청 에러: \(error)")
                }
            }
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
    
    // MARK: - 알림 처리
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        print("📱 푸시 알림 수신: \(userInfo)")
        
        // 채팅 관련 푸시 알림 처리
        if let roomId = userInfo["roomId"] as? String,
           let messageContent = userInfo["content"] as? String {
            handleChatNotification(roomId: roomId, content: messageContent, userInfo: userInfo)
        }
        
        // 다른 타입의 알림 처리
        // TODO: 필요에 따라 추가 구현
    }
    
    private func handleChatNotification(roomId: String, content: String, userInfo: [AnyHashable: Any]) {
        print("💬 채팅 푸시 알림 처리: 방 ID \(roomId), 내용: \(content)")
        
        // 현재 화면이 해당 채팅방인지 확인
        // TODO: 현재 화면 상태에 따른 처리 로직 추가
        
        // WebSocket을 통해 실시간 메시지 동기화
        WebSocketManager.shared.syncChatRoom(roomId: roomId)
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
        
        // 포그라운드에서도 알림 표시
        completionHandler([.banner, .sound, .badge])
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
                NotificationCenter.default.post(
                    name: .navigateToChatRoom,
                    object: nil,
                    userInfo: ["roomId": roomId]
                )
            }
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let navigateToChatRoom = Notification.Name("navigateToChatRoom")
} 
