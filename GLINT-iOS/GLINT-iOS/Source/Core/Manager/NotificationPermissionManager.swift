//
//  NotificationPermissionManager.swift
//  GLINT-iOS
//
//  Created by Claude Code on 8/14/25.
//

import UIKit
import UserNotifications
import Combine

enum NotificationPermissionStatus {
    case notRequested      // 아직 요청하지 않음
    case denied           // 완전 거부
    case authorized       // 완전 허용
    case provisional      // 임시 허용
    case partiallyAuthorized  // 부분 허용 (일부 옵션만 허용)
    
    var isFullyAuthorized: Bool {
        return self == .authorized
    }
    
    var canShowNotifications: Bool {
        return self == .authorized || self == .provisional || self == .partiallyAuthorized
    }
}

struct NotificationAuthorizationDetails {
    let status: NotificationPermissionStatus
    let alertsEnabled: Bool
    let soundsEnabled: Bool
    let badgesEnabled: Bool
    let announceEnabled: Bool
    let lockScreenEnabled: Bool
    let notificationCenterEnabled: Bool
    let carPlayEnabled: Bool
    let criticalAlertsEnabled: Bool
}

@MainActor
final class NotificationPermissionManager: ObservableObject {
    static let shared = NotificationPermissionManager()
    
    @Published var currentStatus: NotificationPermissionStatus = .notRequested
    @Published var authorizationDetails: NotificationAuthorizationDetails?
    @Published var hasRequestedPermissionBefore: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let permissionRequestedKey = "hasRequestedNotificationPermission"
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        hasRequestedPermissionBefore = userDefaults.bool(forKey: permissionRequestedKey)
        setupNotificationObservers()
        
        Task {
            await checkCurrentPermissionStatus()
        }
    }
    
    // MARK: - Permission Status Checking
    
    func checkCurrentPermissionStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        
        let details = NotificationAuthorizationDetails(
            status: mapAuthorizationStatus(settings.authorizationStatus),
            alertsEnabled: settings.alertSetting == .enabled,
            soundsEnabled: settings.soundSetting == .enabled,
            badgesEnabled: settings.badgeSetting == .enabled,
            announceEnabled: settings.announcementSetting == .enabled,
            lockScreenEnabled: settings.lockScreenSetting == .enabled,
            notificationCenterEnabled: settings.notificationCenterSetting == .enabled,
            carPlayEnabled: settings.carPlaySetting == .enabled,
            criticalAlertsEnabled: settings.criticalAlertSetting == .enabled
        )
        
        currentStatus = details.status
        authorizationDetails = details
        
        print("📱 알림 권한 상태 확인:")
        print("   - 전체 상태: \(currentStatus)")
        print("   - 알림: \(details.alertsEnabled)")
        print("   - 소리: \(details.soundsEnabled)")
        print("   - 배지: \(details.badgesEnabled)")
        print("   - 잠금화면: \(details.lockScreenEnabled)")
    }
    
    private func mapAuthorizationStatus(_ status: UNAuthorizationStatus) -> NotificationPermissionStatus {
        switch status {
        case .notDetermined:
            return .notRequested
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .provisional:
            return .provisional
        case .ephemeral:
            return .partiallyAuthorized
        @unknown default:
            return .notRequested
        }
    }
    
    // MARK: - Permission Request
    
    func requestNotificationPermission() async -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge, .providesAppNotificationSettings]
        
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
            
            // 권한 요청 기록 저장
            userDefaults.set(true, forKey: permissionRequestedKey)
            hasRequestedPermissionBefore = true
            
            // 상태 업데이트
            await checkCurrentPermissionStatus()
            
            if granted {
                // APNS 등록
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                print("✅ 알림 권한 허용됨")
                return true
            } else {
                print("❌ 알림 권한 거부됨")
                return false
            }
            
        } catch {
            print("❌ 알림 권한 요청 실패: \(error)")
            return false
        }
    }
    
    // MARK: - Settings Navigation
    
    func openNotificationSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            print("❌ 설정 URL을 생성할 수 없습니다")
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl) { success in
                print(success ? "✅ 설정 화면 열기 성공" : "❌ 설정 화면 열기 실패")
            }
        }
    }
    
    // MARK: - Alternative Notification Methods
    
    func showInAppNotification(title: String, message: String, roomId: String? = nil) {
        guard !currentStatus.canShowNotifications else {
            return // 시스템 알림이 가능하면 인앱 알림 건너뜀
        }
        
        print("📱 인앱 알림 표시: \(title) - \(message)")
        
        // 인앱 알림 표시 로직 (배너, 토스트 등)
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .showInAppNotification,
                object: nil,
                userInfo: [
                    "title": title,
                    "message": message,
                    "roomId": roomId ?? ""
                ]
            )
        }
    }
    
    func updateBadgeCount(_ count: Int) {
        guard authorizationDetails?.badgesEnabled == true else {
            print("📱 배지 권한이 없어 배지 업데이트 건너뜀")
            return
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
            print("📱 배지 업데이트: \(count)")
        }
    }
    
    // MARK: - Permission Guidance
    
    func shouldShowPermissionGuidance() -> Bool {
        return currentStatus == .denied && hasRequestedPermissionBefore
    }
    
    func getPermissionGuidanceMessage() -> String {
        switch currentStatus {
        case .denied:
            return "알림을 받으려면 설정에서 알림을 허용해주세요. 설정 > GLINT > 알림"
        case .partiallyAuthorized:
            return "일부 알림 기능이 제한되어 있습니다. 모든 기능을 사용하려면 설정에서 알림 옵션을 확인해주세요."
        case .notRequested:
            return "새로운 메시지 알림을 받으려면 알림 권한을 허용해주세요."
        default:
            return ""
        }
    }
    
    // MARK: - Notification Observers
    
    private func setupNotificationObservers() {
        // 앱이 활성화될 때 권한 상태 재확인
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                Task {
                    await self?.checkCurrentPermissionStatus()
                }
            }
            .store(in: &cancellables)
        
        // 앱 설정 변경 감지
        NotificationCenter.default.publisher(for: UIApplication.didChangeStatusBarOrientationNotification)
            .sink { [weak self] _ in
                Task {
                    await self?.checkCurrentPermissionStatus()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let showInAppNotification = Notification.Name("showInAppNotification")
    static let notificationPermissionChanged = Notification.Name("notificationPermissionChanged")
}