//
//  AppInitManager.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/10/25.
//

import UIKit
import CoreData

final class AppInitManager {
    static let shared = AppInitManager()
    
    private init() {}
    
    /// 앱 초기화 시 CoreData와 WebSocket 설정 (FCM 제외)
    func setupCoreDataAndWebSocketWithoutFCM() {
        // CoreData 초기화
        setupCoreData()
        
        // 앱 시작 시 오래된 캐시 정리
        cleanupOldCacheOnStartup()
    }
    
    /// 앱 초기화 시 CoreData와 WebSocket 설정 (기존 함수 - 호환성 유지)
    @MainActor
    func setupCoreDataAndWebSocket() {
        setupCoreDataAndWebSocketWithoutFCM()
        
        // FCM 초기화 (APNS 토큰 준비 후 별도 호출 권장)
        setupFCM()
    }
    
    private func setupCoreData() {
        // CoreDataManager 초기화
        let coreDataManager = CoreDataManager.shared
        
        // 앱 종료 시 CoreData 저장
        NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { _ in
            coreDataManager.saveContext()
        }
        
        print("📱 CoreData 초기화 완료")
    }
    
    @MainActor func setupFCM() {
        // FCMManager 초기화 및 설정
        let fcmManager = FCMManager.shared
        fcmManager.configure()
        
        // APNS 토큰 설정 후 FCM 토큰 요청
        fcmManager.requestFCMTokenAfterAPNS()
        
        // 푸시 알림 권한 요청 (약간의 지연 후 요청)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            fcmManager.requestNotificationPermission()
        }
        
        // 토픽 구독은 FCM 토큰 설정 후 자동으로 처리됨
        print("🔥 FCM 초기화 완료")
    }
    
    private func setupBackgroundTasks() {
        // 백그라운드에서 할 수 있는 작업들 등록
        // 추후 BGTaskScheduler 사용
//        print("⏰ 백그라운드 작업 설정 완료")
    }
    
    private func cleanupOldCacheOnStartup() {
        // 앱 시작 시 30일 이상 된 캐시 즉시 정리
        print("🧹 앱 시작 시 오래된 캐시 정리 시작...")
        
        // 백그라운드에서 캐시 정리 수행 (메인 스레드 블로킹 방지)
        Task.detached(priority: .utility) {
            CoreDataManager.shared.cleanupOldFiles(olderThan: 30)
            
            await MainActor.run {
                print("🧹 오래된 캐시 정리 완료")
            }
        }
    }
}
