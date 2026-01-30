//
//  NotificationPreferences.swift
//  GLINT-iOS
//
//  Created by Claude Code on 8/14/25.
//

import Foundation

struct NotificationPreferences: Codable {
    // MARK: - Global Settings
    var globalNotificationsEnabled: Bool
    var quietHoursEnabled: Bool
    var quietHoursStart: Date?
    var quietHoursEnd: Date?
    
    // MARK: - Chat Notifications
    var chatNotificationsEnabled: Bool
    var chatSoundsEnabled: Bool
    var chatVibrationsEnabled: Bool
    var showMessagePreview: Bool
    
    // MARK: - Room-specific Settings
    var mutedRooms: Set<String>
    var favoriteRooms: Set<String>
    
    // MARK: - System Notifications
    var systemNotificationsEnabled: Bool
    var marketingNotificationsEnabled: Bool
    var updateNotificationsEnabled: Bool
    
    // MARK: - Badge Settings
    var badgeCountEnabled: Bool
    var includeSystemInBadge: Bool
    
    // MARK: - Advanced Settings
    var backgroundSyncEnabled: Bool
    var lowPowerModeOptimization: Bool
    
    init() {
        // Default values
        self.globalNotificationsEnabled = true
        self.quietHoursEnabled = false
        self.quietHoursStart = nil
        self.quietHoursEnd = nil
        
        self.chatNotificationsEnabled = true
        self.chatSoundsEnabled = true
        self.chatVibrationsEnabled = true
        self.showMessagePreview = true
        
        self.mutedRooms = Set<String>()
        self.favoriteRooms = Set<String>()
        
        self.systemNotificationsEnabled = true
        self.marketingNotificationsEnabled = false
        self.updateNotificationsEnabled = true
        
        self.badgeCountEnabled = true
        self.includeSystemInBadge = false
        
        self.backgroundSyncEnabled = true
        self.lowPowerModeOptimization = false
    }
}

// MARK: - Room-specific Methods
extension NotificationPreferences {
    mutating func muteRoom(_ roomId: String) {
        mutedRooms.insert(roomId)
    }
    
    mutating func unmuteRoom(_ roomId: String) {
        mutedRooms.remove(roomId)
    }
    
    func isRoomMuted(_ roomId: String) -> Bool {
        return mutedRooms.contains(roomId)
    }
    
    mutating func addFavoriteRoom(_ roomId: String) {
        favoriteRooms.insert(roomId)
    }
    
    mutating func removeFavoriteRoom(_ roomId: String) {
        favoriteRooms.remove(roomId)
    }
    
    func isRoomFavorite(_ roomId: String) -> Bool {
        return favoriteRooms.contains(roomId)
    }
}

// MARK: - Quiet Hours Methods
extension NotificationPreferences {
    func isInQuietHours() -> Bool {
        guard quietHoursEnabled,
              let startTime = quietHoursStart,
              let endTime = quietHoursEnd else {
            return false
        }
        
        let now = Date()
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.hour, .minute], from: now)
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        guard let nowMinutes = nowComponents.hour.map({ $0 * 60 + (nowComponents.minute ?? 0) }),
              let startMinutes = startComponents.hour.map({ $0 * 60 + (startComponents.minute ?? 0) }),
              let endMinutes = endComponents.hour.map({ $0 * 60 + (endComponents.minute ?? 0) }) else {
            return false
        }
        
        // 같은 날 범위인 경우
        if startMinutes <= endMinutes {
            return nowMinutes >= startMinutes && nowMinutes <= endMinutes
        }
        // 자정을 넘나드는 경우 (예: 22:00 ~ 06:00)
        else {
            return nowMinutes >= startMinutes || nowMinutes <= endMinutes
        }
    }
    
    mutating func setQuietHours(enabled: Bool, start: Date? = nil, end: Date? = nil) {
        quietHoursEnabled = enabled
        if enabled {
            quietHoursStart = start
            quietHoursEnd = end
        }
    }
}

// MARK: - Notification Decision Logic
extension NotificationPreferences {
    func shouldShowChatNotification(for roomId: String, isInForeground: Bool, isActiveRoom: Bool) -> Bool {
        // 1. 전역 알림이 비활성화된 경우
        guard globalNotificationsEnabled else { return false }
        
        // 2. 채팅 알림이 비활성화된 경우
        guard chatNotificationsEnabled else { return false }
        
        // 3. 해당 방이 음소거된 경우
        guard !isRoomMuted(roomId) else { return false }
        
        // 4. 조용한 시간인 경우 (즐겨찾기 방은 예외)
        if isInQuietHours() && !isRoomFavorite(roomId) {
            return false
        }
        
        // 5. 포그라운드에서 현재 활성 방인 경우 (인앱으로만 표시)
        if isInForeground && isActiveRoom {
            return false
        }
        
        return true
    }
    
    func shouldPlayNotificationSound(for roomId: String) -> Bool {
        guard chatSoundsEnabled else { return false }
        guard !isInQuietHours() else { return false }
        return true
    }
    
    func shouldVibrate(for roomId: String) -> Bool {
        guard chatVibrationsEnabled else { return false }
        guard !isInQuietHours() else { return false }
        return true
    }
}

// MARK: - UserDefaults Storage
final class NotificationPreferencesManager {
    static let shared = NotificationPreferencesManager()
    
    private let userDefaults = UserDefaults.standard
    private let preferencesKey = "notificationPreferences"
    
    private init() {}
    
    func loadPreferences() -> NotificationPreferences {
        guard let data = userDefaults.data(forKey: preferencesKey),
              let preferences = try? JSONDecoder().decode(NotificationPreferences.self, from: data) else {
            // 기본값 반환
            let defaultPreferences = NotificationPreferences()
            savePreferences(defaultPreferences)
            return defaultPreferences
        }
        
        return preferences
    }
    
    func savePreferences(_ preferences: NotificationPreferences) {
        do {
            let data = try JSONEncoder().encode(preferences)
            userDefaults.set(data, forKey: preferencesKey)
            userDefaults.synchronize()
            
            // 변경 알림 발송
            NotificationCenter.default.post(
                name: .notificationPreferencesDidChange,
                object: nil,
                userInfo: ["preferences": preferences]
            )
            
            print("✅ 알림 설정 저장 완료")
        } catch {
            print("❌ 알림 설정 저장 실패: \(error)")
        }
    }
    
    // MARK: - Quick Access Methods
    
    func muteRoom(_ roomId: String) {
        var preferences = loadPreferences()
        preferences.muteRoom(roomId)
        savePreferences(preferences)
    }
    
    func unmuteRoom(_ roomId: String) {
        var preferences = loadPreferences()
        preferences.unmuteRoom(roomId)
        savePreferences(preferences)
    }
    
    func toggleRoomMute(_ roomId: String) {
        var preferences = loadPreferences()
        if preferences.isRoomMuted(roomId) {
            preferences.unmuteRoom(roomId)
        } else {
            preferences.muteRoom(roomId)
        }
        savePreferences(preferences)
    }
    
    func isRoomMuted(_ roomId: String) -> Bool {
        return loadPreferences().isRoomMuted(roomId)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let notificationPreferencesDidChange = Notification.Name("notificationPreferencesDidChange")
}