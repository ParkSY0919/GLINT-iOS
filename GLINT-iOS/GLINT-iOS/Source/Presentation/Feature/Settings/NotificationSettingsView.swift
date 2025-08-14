//
//  NotificationSettingsView.swift
//  GLINT-iOS
//
//  Created by Claude Code on 8/14/25.
//

import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var permissionManager = NotificationPermissionManager.shared
    @StateObject private var appStateManager = AppStateManager.shared
    @State private var preferences = NotificationPreferencesManager.shared.loadPreferences()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                // 권한 상태 섹션
                permissionStatusSection
                
                // 전역 설정 섹션
                globalSettingsSection
                
                // 채팅 알림 설정 섹션
                chatNotificationSection
                
                // 조용한 시간 설정 섹션
                quietHoursSection
                
                // 시스템 알림 설정 섹션
                systemNotificationSection
                
                // 고급 설정 섹션
                advancedSettingsSection
            }
            .navigationTitle("알림 설정")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("취소") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("저장") {
                    savePreferences()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            Task {
                await permissionManager.checkCurrentPermissionStatus()
            }
        }
    }
    
    // MARK: - Permission Status Section
    private var permissionStatusSection: some View {
        Section("알림 권한 상태") {
            HStack {
                Image(systemName: permissionStatusIcon)
                    .foregroundColor(permissionStatusColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(permissionStatusTitle)
                        .font(.headline)
                    
                    if !permissionStatusMessage.isEmpty {
                        Text(permissionStatusMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if permissionManager.shouldShowPermissionGuidance() {
                    Button("설정") {
                        permissionManager.openNotificationSettings()
                    }
                    .font(.caption)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Global Settings Section
    private var globalSettingsSection: some View {
        Section("전체 설정") {
            Toggle("알림 허용", isOn: $preferences.globalNotificationsEnabled)
                .disabled(!permissionManager.currentStatus.canShowNotifications)
            
            if preferences.globalNotificationsEnabled {
                Toggle("배지 표시", isOn: $preferences.badgeCountEnabled)
                    .disabled(permissionManager.authorizationDetails?.badgesEnabled != true)
            }
        }
    }
    
    // MARK: - Chat Notification Section
    private var chatNotificationSection: some View {
        Section("채팅 알림") {
            Toggle("채팅 알림", isOn: $preferences.chatNotificationsEnabled)
                .disabled(!preferences.globalNotificationsEnabled)
            
            if preferences.chatNotificationsEnabled {
                Toggle("알림음", isOn: $preferences.chatSoundsEnabled)
                    .disabled(permissionManager.authorizationDetails?.soundsEnabled != true)
                
                Toggle("진동", isOn: $preferences.chatVibrationsEnabled)
                
                Toggle("메시지 미리보기", isOn: $preferences.showMessagePreview)
            }
        }
    }
    
    // MARK: - Quiet Hours Section
    private var quietHoursSection: some View {
        Section("조용한 시간") {
            Toggle("조용한 시간 사용", isOn: $preferences.quietHoursEnabled)
            
            if preferences.quietHoursEnabled {
                DatePicker(
                    "시작 시간",
                    selection: Binding(
                        get: { preferences.quietHoursStart ?? Date() },
                        set: { preferences.quietHoursStart = $0 }
                    ),
                    displayedComponents: .hourAndMinute
                )
                
                DatePicker(
                    "종료 시간",
                    selection: Binding(
                        get: { preferences.quietHoursEnd ?? Date() },
                        set: { preferences.quietHoursEnd = $0 }
                    ),
                    displayedComponents: .hourAndMinute
                )
                
                Text("조용한 시간에는 즐겨찾기한 채팅방을 제외하고 알림이 표시되지 않습니다.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - System Notification Section
    private var systemNotificationSection: some View {
        Section("시스템 알림") {
            Toggle("시스템 알림", isOn: $preferences.systemNotificationsEnabled)
                .disabled(!preferences.globalNotificationsEnabled)
            
            Toggle("업데이트 알림", isOn: $preferences.updateNotificationsEnabled)
                .disabled(!preferences.globalNotificationsEnabled)
            
            Toggle("마케팅 알림", isOn: $preferences.marketingNotificationsEnabled)
                .disabled(!preferences.globalNotificationsEnabled)
        }
    }
    
    // MARK: - Advanced Settings Section
    private var advancedSettingsSection: some View {
        Section("고급 설정") {
            Toggle("백그라운드 동기화", isOn: $preferences.backgroundSyncEnabled)
            
            Toggle("절전 모드 최적화", isOn: $preferences.lowPowerModeOptimization)
            
            HStack {
                Text("배지에 시스템 알림 포함")
                Spacer()
                Toggle("", isOn: $preferences.includeSystemInBadge)
                    .labelsHidden()
            }
        }
    }
    
    // MARK: - Helper Computed Properties
    private var permissionStatusIcon: String {
        switch permissionManager.currentStatus {
        case .authorized:
            return "checkmark.circle.fill"
        case .denied:
            return "xmark.circle.fill"
        case .partiallyAuthorized:
            return "exclamationmark.triangle.fill"
        case .provisional:
            return "clock.circle.fill"
        case .notRequested:
            return "questionmark.circle.fill"
        }
    }
    
    private var permissionStatusColor: Color {
        switch permissionManager.currentStatus {
        case .authorized:
            return .green
        case .denied:
            return .red
        case .partiallyAuthorized:
            return .orange
        case .provisional:
            return .yellow
        case .notRequested:
            return .gray
        }
    }
    
    private var permissionStatusTitle: String {
        switch permissionManager.currentStatus {
        case .authorized:
            return "알림 허용됨"
        case .denied:
            return "알림 거부됨"
        case .partiallyAuthorized:
            return "부분 허용됨"
        case .provisional:
            return "임시 허용됨"
        case .notRequested:
            return "권한 미요청"
        }
    }
    
    private var permissionStatusMessage: String {
        return permissionManager.getPermissionGuidanceMessage()
    }
    
    // MARK: - Actions
    private func savePreferences() {
        NotificationPreferencesManager.shared.savePreferences(preferences)
    }
}

// MARK: - Preview
struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
    }
}