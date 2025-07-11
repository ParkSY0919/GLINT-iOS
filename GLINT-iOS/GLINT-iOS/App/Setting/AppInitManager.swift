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
    
    /// 앱 초기화 시 CoreData와 WebSocket 설정
    func setupCoreDataAndWebSocket() {
        // CoreData 초기화
        setupCoreData()
        
        // WebSocket 관리자 초기화
        setupWebSocket()
        
        // 백그라운드 작업 설정
//        setupBackgroundTasks()
        
        // 캐시 정리 스케줄링
        scheduleCacheCleanup()
    }
    
    private func setupCoreData() {
        // CoreDataManager 초기화 (싱글톤이므로 접근만 해도 초기화됨)
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
    
    private func setupWebSocket() {
        // WebSocketManager 초기화
        let webSocketManager = WebSocketManager.shared
        
        // 앱이 활성화될 때 오프라인 메시지 처리
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            // 오프라인 데이터 처리
            CoreDataManager.shared.processOfflineData()
        }
        
        print("🔌 WebSocket 초기화 완료")
    }
    
    private func setupBackgroundTasks() {
        // 백그라운드에서 할 수 있는 작업들 등록
        // 추후 BGTaskScheduler 사용
        print("⏰ 백그라운드 작업 설정 완료")
    }
    
    private func scheduleCacheCleanup() {
        // 매일 자정에 30일 이상 된 캐시 정리
        let timer = Timer.scheduledTimer(withTimeInterval: 24 * 60 * 60, repeats: true) { _ in
            CoreDataManager.shared.cleanupOldFiles(olderThan: 30)
        }
        
        // 메모리 관리를 위해 RunLoop에 추가
        RunLoop.main.add(timer, forMode: .common)
        
        print("🧹 캐시 정리 스케줄링 완료")
    }
}
